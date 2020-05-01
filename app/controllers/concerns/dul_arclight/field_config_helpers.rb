# frozen_string_literal: true

# Extend ArcLight core's field configuration helpers. See:
# https://github.com/projectblacklight/arclight/blob/master/app/controllers/concerns/arclight/field_config_helpers.rb

module DulArclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    extend ActiveSupport::Concern
    include Arclight::FieldConfigHelpers

    included do
      if respond_to?(:helper_method)
        helper_method :singularize_extent
      end
    end

    # Use singular form of descriptors for extents like "1 boxes", "1 folders", or "1 albums".
    # ASpace output frequently produces such strings.
    def singularize_extent(args)
      options = args[:config].try(:separator_options) || {}
      values = args[:value] || []
      return unless values.present?

      values.map! do |value|
        correct_singular_value(value)
      end.to_sentence(options).html_safe
    end

    def correct_singular_value(value)
      chars_before_space = value.match(/([^\s]+)/)
      %w[1 1.0].include?(chars_before_space.to_s) ? value.singularize : value
    end
  end
end
