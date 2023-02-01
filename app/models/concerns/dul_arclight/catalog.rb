# frozen_string_literal: true

# Modifies some ArcLight core methods to account for the
# DUL custom child_components view. Last checked for updates
# ArcLight v0.3.0. See:
# https://github.com/projectblacklight/arclight/blob/master/app/models/concerns/arclight/catalog.rb
#
module DulArclight
  ##
  # DUL-ArcLight specific methods for the Catalog Controller
  module Catalog
    extend ActiveSupport::Concern
    include Arclight::Catalog

    # DUL CUSTOMIZATION: send the source EAD XML file that we already have on the filesystem
    # Modeled after "raw", see:
    # https://github.com/projectblacklight/blacklight/blob/master/app/controllers/concerns/blacklight/catalog.rb#L65-L71
    def ead_download
      _, @document = search_service.fetch(params[:id])
      xml_filename = ead_file_path
      
      if xml_filename.nil?
        render plain: '404 Not Found', status: :not_found
        return
      end

      send_file(
        ead_file_path,
        filename: "#{params[:id]}.xml",
        disposition: 'inline',
        type: 'text/xml'
      )
    end

    def html_download
      _, @document = search_service.fetch(params[:id])

      headers['Content-Type'] = 'text/html'
      headers['X-Accel-Buffering'] = 'no' # Stop NGINX from buffering
      headers.delete('Content-Length')
      headers.delete('ETag')

      # replace m-arclight-placeholder with current asset styles/scripts
      self.response_body = Enumerator.new do |output|
        File.foreach(html_file_path) do |line|
          if line.index('<m-arclight-placeholder></m-arclight-placeholder>')
            output << helpers.stylesheet_link_tag('application', media: 'all')
            output << helpers.javascript_include_tag('application')
            output << helpers.csrf_meta_tags
            next
          end
          output << line
        end
      end
    end

    def pdf_download
      _, @document = search_service.fetch(params[:id])
      send_file(
        pdf_file_path,
        filename: "#{params[:id]}.pdf",
        disposition: 'attachment',
        type: 'application/pdf'
      )
    end

    def pdf_available?
      # _, @document = search_service.fetch(params[:id])
      File.exist?(pdf_file_path)
    end

    ##
    # Overriding the Blacklight method so that the hierarchy view does not start
    # a new search session
    def start_new_search_session?
      !%w[online_contents collection_context child_components].include?(params[:view]) && super
    end

    ##
    # Overriding the Blacklight method so that hierarchy does not get stored as
    # the preferred view
    def store_preferred_view
      return if %w[online_contents collection_context child_components].include?(params[:view])

      super
    end

    private

    def ead_file_path
      # look for the document eadid first
      filename = File.join(DulArclight.finding_aid_data, 'ead', repo_id, "#{eadid}.xml")
      return filename if File.exist?(filename)

      # look for a filename based on publicid_ssi
      publicid = @document.publicid
      match = publicid.match(/us::miu-c::(.*)\/\/EN/)
      filename = File.join(DulArclight.finding_aid_data, 'ead', repo_id, match[1])
      return filename if File.exist?(filename)

      nil
    end

    def html_file_path
      File.join(DulArclight.finding_aid_data, 'pdf', repo_id, "#{eadid}.html")
    end

    def pdf_file_path
      File.join(DulArclight.finding_aid_data, 'pdf', repo_id, "#{eadid}.pdf")
    end

    def repo_id
      @document.repository_config&.slug
    end

    def eadid
      @document.eadid
    end
  end
end
