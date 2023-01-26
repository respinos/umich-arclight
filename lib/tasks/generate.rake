require 'arclight'
require 'arclight/repository'

require 'um_arclight/package/generator'

namespace :arclight do
  artifact = nil

  desc 'Generate packages for indexed finding aids via background jobs'
  task generate_enqueue: :environment do
    repository_ssm = nil
    if ENV['REPOSITORY_ID']
      repository_config = Arclight::Repository.find_by(slug: ENV['REPOSITORY_ID'])
      repository_ssm = repository_config.name
    end
    UmArclight::Package::Queue.new.setup(repository_ssm: repository_ssm)
  end

  desc 'Build a full HTML out of an EAD document, use EADID=<id>'
  task generate_html: :environment do
    raise 'Please specify your EAD ID, ex. EADID=<id>' unless ENV['EADID']

    identifier = ENV['EADID']

    artifact = UmArclight::Package::Generator.new identifier: identifier
    artifact.generate_html
  end

  desc 'Build a PDF out of an EAD document, use EADID=<id>'
  task generate_pdf: :generate_html do
    # now set up the doc for the HTML PDF
    artifact.generate_pdf
  end
end
