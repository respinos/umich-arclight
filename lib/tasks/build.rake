require 'arclight'
require 'benchmark'
require 'json'
require 'fileutils'
require 'puppeteer-ruby'

def _pluralize_ssi(hash)
  hash.keys.each do |key|
    unless hash[key].is_a?(Array)
      hash[key] = [ hash[key] ]
    end
  end
  hash
end

namespace :arclight do
  desc 'Build a PDF out of an EAD document, use FILE=<path/to/ead.xml> and REPOSITORY_ID=<myid>'
  task :build_pdf do
    print "Hey\n"
    raise 'Please specify your EAD document, ex. FILE=<path/to/ead.xml>' unless ENV['FILE']
    unless Dir.exists?("./tmp/pdf")
      Dir.mkdir("./tmp/pdf")
      print "Made tmp/pdf\n"
    end
    output_filename = File.basename(ENV['FILE'], '.xml')
    elapsed_time = Benchmark.realtime do
      `bundle exec traject -i xml -c ./lib/dul_arclight/traject/ead2_config.rb -c ./lib/dul_arclight/traject/pdf_config.rb -o ./tmp/pdf/#{output_filename}.pdf #{ENV['FILE']}`
    end
    print "Built PDF for #{ENV['FILE']} (in #{elapsed_time.round(3)} secs).\n"
  end

  desc 'Build a PDF out a directory of EADs, use DIR=<path/to/directory> and REPOSITORY_ID=<myid>'
  task :build_pdf_dir do
    raise 'Please specify your directory, ex. DIR=<path/to/directory>' unless ENV['DIR']

    Dir.glob(File.join(ENV['DIR'], '*.xml')).each do |file|
      system("rake arclight:build_pdf FILE=#{file}")
    end
  end

  task :build_html => :environment do
    raise 'Please specify your EAD ID, ex. EADID=<id>' unless ENV['EADID']
    identifier = ENV['EADID']

    settings = {}
    settings['output_file'] = "#{Rails.root}/tmp/pdf"

    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.host = 'findingaids.lib.umich.edu'
    session.https!(true)

    session.get("/catalog/#{identifier}")
    body = session.response.body

    doc = Nokogiri::HTML5(body)
    style_el = doc.xpath('/html/head/link[@rel="stylesheet"]').last

    repository = Blacklight.repository_class.new(CatalogController.new.helpers.blacklight_config)

    ## fetch the full collection document
    params = {
      fl: '*',
      q: [ "id:#{identifier}"],
      start: 0,
      rows: 1000
    }
    response = repository.search(params)
    collection = response.documents.first

    ## fetch a more focused set of properties for containers

    component_fl = [
      'id',
      'parent_ssi',
      'parent_ssim',
      'ref_ssi',
      'ref_ssm',
      'component_level_isim',
      'normalized_title_ssm',
      'level_ssm',
      'scopecontent_teism',
      'unitid_ssm',
      'odd_tesim',
      'bioghist_tesim',
      'total_digital_object_count_isim',
      'digital_objects_ssm',
      'containers_ssim',
      'repository_ssm',
    ]

    params = {
      fl: component_fl.join(','),
      q: [ "ead_ssi:#{identifier}"],
      start: 0,
      rows: 1000
    }
    components = []
    response = repository.search(params)
    total = response.total
    start = 0
    while ( response.documents.present? )
      STDERR.puts "-- harvesting: #{start} / #{total}"
      response.documents.each do |doc|
        if doc.id == identifier
          # ignore the collection doc
          next
        end
        components << doc
      end
      start += 1000
      params[:start] = start
      response = repository.search(params)
    end

    STDERR.puts "-- # : #{total} :: #{components.length}"
    
    File.open("#{settings["output_file"]}/#{identifier}.components.json", "w") do |f|
      f.puts JSON.pretty_generate(components.map { |v| v.to_h })
    end

    paths = ActionView::PathSet.new(["app/views"])
    lookup_context = ActionView::LookupContext.new(paths)
    renderer = ActionView::Renderer.new(lookup_context)
    view_context = ActionView::Base.new(renderer)
    # overwrite the repository name in hash with the true repository object
    view_context.assign({ 
      repository: collection.repository_config,
      collection: collection,
      components: components
    })
    view_context.extend Arclight::EadFormatHelpers

    fragment_html = renderer.render(view_context, template: 'arclight/pdf/fragment')
    
    fragment = Nokogiri::HTML5(fragment_html)

    File.open("#{settings["output_file"]}/#{identifier}.fragment.html", "w") do |f|
      f.puts fragment_html
    end

    doc.css('#about-collection-nav a').each do |link|
      href = link['href']
      link['href'] = '#' + href.split('#').last
    end

    # customize the view=all HTML
    style_el.add_next_sibling(fragment.css('#utility-styles').first)
    doc.css('#summary dl').first << fragment.css('dl#ead_author_block dt,dd')
    doc.css('#background').first << fragment.css('#revdesc_changes')
    doc.css('div.al-contents').first.replace(fragment.css('div.al-contents-ish').first)
    doc.css('body').first << fragment.css('script').first
    doc.css('.card-img').first.remove
    doc.css('#navigate-collection-toggle').first.remove
    doc.css('#context-tree-nav .tab-pane.active').first.inner_html = '<div id="toc"><ul></ul></div>';

    File.open("#{settings["output_file"]}/#{identifier}.html", "w") do |f|
      f.puts doc.serialize
    end

    # now set up the doc for the HTML PDF
    Dir.chdir(settings['output_file'])
    unless Dir.exists?('assets')
      Dir.mkdir('assets')
    end

    doc.css('.access-preview-snippet').first.inner_html = '<div id="toc"><ul></ul></div>'
    doc.css('m-website-header').first.replace(fragment.css('header').first)
    doc.css('footer').first.remove
    doc.css('div.x-printable').remove
    doc.xpath('/html/head/link').each do |link|
      if link['rel'] == 'stylesheet' && link['href'].start_with?('/assets/')
        session.get(link['href'])
        stylesheet = session.response.body

        # now we have to look for url(/assets) here
        buffer = stylesheet.split(/\n/)
        buffer.each_with_index do |line, i|
          if matches = line.scan(/url\(\/assets\/([^\)]+)\)/)
            matches.each do |match|
              session.get("/assets/#{match[0]}")
              resource = session.response.body

              filename = match[0].split(/[\?#]/).first

              unless Dir.exists?("assets/#{filename}")
                FileUtils.makedirs("assets/#{File.dirname(filename)}")
              end

              File.open("./assets/#{filename}", "wb") do |f|
                f.puts resource
              end
              content_type = session.response.content_type
              # resource_data = Base64.encode64(resource).gsub(/\n/, '')
              # line.gsub!("/assets/#{match[0]}", "data:#{content_type};charset=utf-8;base64,#{resource_data}")
              line.gsub!("/assets/#{match[0]}", "./assets/#{filename}")
              STDERR.puts "--- YIKES #{content_type} :: #{filename}"
            end
            buffer[i] = line
          end
        end
        # stylesheet = buffer.join("\n")
        # style_el = link.replace('<style>' + stylesheet + '</style>')

        filename = link['href'].split(/[\?#]/).first

        unless Dir.exists?(".#{File.dirname(filename)}")
          FileUtils.makedirs(".#{File.dirname(filename)}")
        end

        File.open(".#{filename}", "wb") do |f|
          f.puts stylesheet
        end
        link['href'] = ".#{filename}"
      end
    end
    # and remove the script tags
    doc.xpath('/html/head/script').each do |script|
      script.remove
    end

    doc.root['data-media'] = 'print'

    print_html = doc.serialize
    File.open("#{settings["output_file"]}/#{identifier}.local.html", "w") do |f|
      f.puts print_html
    end

    elapsed_time = Benchmark.realtime do
      STDERR.puts "file:/#{settings['output_file']}/#{identifier}.local.html"
      Puppeteer.launch(headless: true, args: [ '--no-sandbox', '--disable-setuid-sandbox' ]) do |browser|
        page = browser.new_page
        # page.goto("file:///Users/roger/Projects/sandbox/ruby-pdf/sample1.html")
        # page.content = result
        # page.set_content(print_html, wait_until: 'networkidle2')
        page.goto("file://#{settings['output_file']}/#{identifier}.local.html", wait_until: 'networkidle2')
        page.pdf(
          path: "#{settings["output_file"]}/#{identifier}.pdf",
          print_background: true,
          omit_background: false,
          display_header_footer: false,
          timeout: 300000,
          footer_template: '<div style="font-weight: bold">Generated by findingaids.lib.umich.edu</div>',
          margin: {
            top: 50,
            right: 70,
            bottom: 70,
            left: 70
          },
        )
      end
    end
    STDERR.puts "-- Build PDF: puppeteer render (in #{elapsed_time.round(3)} secs)."
  end    

end