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
        helper_method :render_links
        helper_method :singularize_extent
        helper_method :link_to_ua_record_group_facet
        helper_method :ua_record_group_display
        helper_method :convert_rights_urls
        helper_method :keep_raw_values
        helper_method :render_bioghist
      end
    end

    # Sometimes we really just want to return an array and not use Blacklight's default
    # Array#to_sentence
    def keep_raw_values(args)
      args[:value] || []
    end

    def render_bioghist(args)
      html = render_html_tags(args)

      if args[:value].length > 1 && args[:value][0].include?("&lt;head&gt;")
        output = []
        for i in 0...args[:value].length do
          raw_html = CGI::unescape_html(args[:value][i].gsub(/<\/?p>/,"").strip)
          with_headers = raw_html.gsub("<head>", "<strong>").gsub("</head>", "</strong>")
          output.append(render_html_tags({value:[with_headers]}))
        end
        doc = Nokogiri::HTML.fragment(output.join(""))
        doc.to_html.html_safe
      else
        html
      end

    end

    def convert_rights_urls(args)
      html = render_html_tags(args)
      doc = Nokogiri::HTML.fragment(html)

      doc.css('p').map do |p|
        if just_a_url?(p.text) && configured_rights_url?(p.text)
          p.add_class('rights-statement')
          p.inner_html = rights_logo(p.text).html_safe
        else
          p.inner_html = view_context.auto_link(p.inner_html).html_safe
        end
      end
      doc.to_html.html_safe
    end

    def render_links(args)
      options = args[:config].try(:separator_options) || {}
      values = args[:value] || []

      values.map do |value|
        view_context.link_to(value, value)
      end.to_sentence(options).html_safe
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

    # Override existing ArcLight core helper to support .html_safe
    def context_access_tab_visit_note(args)
      document = args[:document]
      document.repository_config.visit_note.html_safe
    end

    private

    def just_a_url?(text)
      text.strip.start_with?(URI::DEFAULT_PARSER.make_regexp) && !text.strip.match(/\s/)
    end

    def configured_rights_url?(url)
      RIGHTS_STATEMENTS.key?(url)
    end

    def rights_logo(url)
      statement = RIGHTS_STATEMENTS.dig(url)
      view_context.link_to(
        [all_svg_icon_tags(statement), statement.dig('title')].join.html_safe,
        url, rel: 'license', itemprop: 'license', target: '_blank'
      )
    end

    def all_svg_icon_tags(statement)
      tags = ''.dup
      configured_icons(statement).each do |i|
        tags << svg_icon_tag(i)
      end
      tags
    end

    def configured_icons(statement)
      statement.select { |k, _v| k.start_with?('icon_') }.values
    end

    def svg_icon_tag(slug)
      # decorative images should have blank alt text
      view_context.image_tag(svg_icon_path(slug), class: 'rights-icon', alt: '')
    end

    def svg_icon_path(slug)
      view_context.asset_path(['icons/rights/', slug, '.svg'].join)
    end
  end
end
