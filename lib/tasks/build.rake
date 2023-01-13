require 'arclight'
require 'arclight/repository'

require 'um_arclight/package/generator'
require 'pp'

namespace :arclight do
  artifact = nil

  desc 'Generate packages for indexed finding aids via background jobs'
  task :queue_pdf => :environment do
    repository_ssm = nil
    if ENV['REPOSITORY_ID']
      repository_config = Arclight::Repository.find_by(slug: ENV['REPOSITORY_ID'])
      repository_ssm = repository_config.name
    end
    UmArclight::Package::Generator.queue_build(repository_ssm: repository_ssm)
  end

  task :build_html => :environment do
    raise 'Please specify your EAD ID, ex. EADID=<id>' unless ENV['EADID']
    identifier = ENV['EADID']

    artifact = UmArclight::Package::Generator.new identifier: identifier
    artifact.build_html
  end    

  desc 'Build a PDF out of an EAD document, use FILE=<path/to/ead.xml> and REPOSITORY_ID=<myid>'
  task :build_pdf => :build_html do
    # now set up the doc for the HTML PDF

    artifact.build_pdf


  end

end