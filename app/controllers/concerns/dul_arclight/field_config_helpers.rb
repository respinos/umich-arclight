# frozen_string_literal: true

# Extend ArcLight core's field configuration helpers. See:
# https://github.com/projectblacklight/arclight/blob/master/app/controllers/concerns/arclight/field_config_helpers.rb
#
module DulArclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    extend ActiveSupport::Concern
    include Arclight::FieldConfigHelpers
    include HierarchyHelper

    included do
      if respond_to?(:helper_method)
        helper_method :singularize_extent
        helper_method :link_to_ua_record_group_facet
        helper_method :ua_record_group_display
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

    def link_to_ua_record_group_facet(args)
      options = args[:config].try(:separator_options) || {}
      values = args[:value] || []
      values.map do |value|
        view_context.link_to(
          ua_record_group_display(value),
          view_context.search_action_path(f: { ua_record_group_ssim: [value] })
        )
      end.to_sentence(options).html_safe
    end

    # Map the UA record group codes to display their titles instead - this only works in the
    # facet selection history and in links in the collection metadata, not the facet itself. See
    # hierarchy_helper.rb for the facet rendering logic.

    # subgroup_label & group_label are defined in hierarchy_helper.rb

    def ua_record_group_display(value = '')
      group_keys = value.split(':')
      label = [group_keys.last, ' &mdash; '].join
      label << (group_keys.count > 1 ? subgroup_label(group_keys) : group_label(group_keys))
      label.html_safe
    end
  end
end
