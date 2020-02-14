# frozen_string_literal: true

# Modeled loosely on existing ArcLight core requests:
# https://github.com/projectblacklight/arclight/blob/master/app/models/arclight/requests/google_form.rb
# https://github.com/projectblacklight/arclight/blob/master/app/models/arclight/requests/aeon_web_ead.rb

module Arclight
  module Requests
    ##
    class DukeRequest
      attr_reader :document

      ##
      # @param [Blacklight::SolrDocument] document
      def initialize(document)
        @document = document
      end

      ##
      # Base url of request link
      def base_request_url
        document.repository_config&.request_url_for_type('duke_request')
      end

      ##
      # Full url of request link
      def url
        [base_request_url, document.bibnum].join
      end
    end
  end
end
