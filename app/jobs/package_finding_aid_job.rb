# frozen_string_literal: true

require 'um_arclight/errors'
require 'um_arclight/package/generator'

# Job to queue packaging
class PackageFindingAidJob < ApplicationJob
  queue_as :index

  def perform(identifier, format)
    artifact = UmArclight::Package::Generator.new identifier: identifier
    format == 'html' ? artifact.generate_html : artifact.generate_pdf
  rescue StandardError
    raise UmArclight::GenerateError, identifier
  end
end
