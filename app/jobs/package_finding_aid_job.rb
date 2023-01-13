require 'dul_arclight/errors'
require 'um_arclight/package/generator'

class PackageFindingAidJob < ApplicationJob
  queue_as :index

  def perform(identifier)
    begin
      artifact = UmArclight::Package::Generator.new identifier: identifier
      artifact.build_html
      artifact.build_pdf
    rescue StandardError => e
      raise UmArclight::PackageError, e
    end
  end

end