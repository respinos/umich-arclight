require 'dul_arclight/errors'
require 'um_arclight/package/generator'

class PackageFindingAidJob < ApplicationJob
  queue_as :index

  def perform(identifier)
    begin
      artifact = UmArclight::Package::Generator.new identifier: identifier
      artifact.generate_html
      artifact.generate_pdf
    rescue StandardError => e
      raise UmArclight::PackageError, e
    end
  end

end