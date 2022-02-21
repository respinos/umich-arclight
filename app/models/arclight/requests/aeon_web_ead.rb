# frozen_string_literal: true

module Arclight
  module Requests
    ##
    # This object relies on the ability to respond to attributes passed in as
    # query parameters from the form mapping configuration
    class AeonWebEad
      attr_reader :document, :ead_url
      ##
      # @param [Blacklight::SolrDocument] document
      # @param [String] ead_url
      def initialize(document, ead_url)
        @document = document
        @ead_url = ead_url
      end

      ##
      # Url target for Aeon request params
      def request_url
        document.repository_config.request_url_for_type('aeon_web_ead')
      end

      ##
      # Constructed request URL
      def url
        "#{request_url}?#{form_mapping.to_query}"
      end

      def parsed_ead_url
        return ead_url unless document.repository_config.request_id_present?

        field = document.repository_config.request_field
        pattern = document.repository_config.request_pattern
        prefix = document.repository_config.request_prefix

        request_id = document.request_field(field)
        if pattern
          regexed_id = Regexp::new(pattern).match(request_id)
          if regexed_id
            request_id = regexed_id[1]
          end
        end

        "#{prefix}#{request_id}"
      end

      ##
      # Converts mappings as a query url param into a Hash used for sending
      # messages
      # If a defined method is provided as a value, that method will be invoked
      # "collection_name=entry.123" => { "collection_name" => "entry.123" }
      # @return [Hash]
      def form_mapping
        form_hash = Rack::Utils.parse_nested_query(
          document.repository_config.request_mappings_for_type('aeon_web_ead')
        )
        form_hash.each do |key, value|
          respond_to?(value) && form_hash[key] = send(value)
        end
        form_hash
      end
    end
  end
end
