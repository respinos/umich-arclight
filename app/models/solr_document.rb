# frozen_string_literal: true

require 'dul_arclight/digital_object'

class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument
  include DulArclight::FieldConfigHelpers

  # self.unique_key = 'id'

  # DUL CUSTOMIZATION: Allow for formatting tags to render in collection/component
  # titles in some views.
  def normalized_title
    value = first('normalized_title_formatted_ssm') || first('normalized_title_ssm').to_s
    render_html_tags(value: [value]) if value.present?
  end

  def bibnums
    fetch('bibnum_ssim', [])
  end

  def score
    fetch('score', [])
  end

  # DUL-specific language display logic: If there's at least one <langmaterial> with no
  # child <language>, use that/those. Fall back to using langmaterial/language values.
  def languages
    fetch('langmaterial_ssm') { fetch('language_ssm', []) }
  end

  # DUL override ArcLight core method to reflect changing the fields from _sim to _tesim
  def abstract_or_scope
    value = first('abstract_tesim') || first('scopecontent_tesim').to_s
    render_html_tags(value: [value]) if value.present?
  end

  # DUL override ArcLight core method, which was incorrectly lowercasing subsequent characters in
  # attempt to capitalize the first letter; See:
  # https://github.com/projectblacklight/arclight/blob/master/app/models/concerns/arclight/solr_document.rb#L124-L127
  def containers
    fetch('containers_ssim', []).map do |container|
      container[0] = container[0].capitalize
      container
    end
  end

  def component?
    parent_ids.present?
  end

  def restricted_component?
    component? && (fetch('accessrestrict_tesim', []).present? || fetch('userestrict_tesim', []).present?)
  end

  def total_component_count
    first('total_component_count_isim') || 0
  end

  # DUL override ArcLight core; we want all extent values, and to singularize e.g. 1 boxes.
  # We'll use document.extent for the "extent badge", which excludes other physdec text.
  # beyond extent that we want to appear in collection/component show views.
  def extent
    values = fetch('extent_ssm', []).map! do |value|
      correct_singular_value(value)
    end
    values.join(' &mdash; ').html_safe if values.present?
  end

  # ==============================
  # Highlights (for query matches)
  # ==============================

  # DUL-Custom methods for highlighting search terms in search results views.
  # We want to be able to highlight the keyword within the component title in a
  # search result, and don't want to repeat the title in the highlights section if
  # it is the text that matched the query (true for the vast majority of searches).

  # TODO: write some tests for this customization.

  def title_with_highlighting
    highlights[highlight_index].html_safe if title_should_have_highlighting?
  end

  def highlights_without_title
    highlights&.reject! { |h| h[highlight_index] if highlight_index.present? }
    highlights
  end

  # ===============
  # Digital Objects
  # ===============

  def digital_objects
    digital_objects_field = fetch('digital_objects_ssm', []).reject(&:empty?)
    return [] if digital_objects_field.blank?

    digital_objects_field.map do |object|
      DulArclight::DigitalObject.from_json(object)
    end
  end

  def non_ddr_digital_objects
    digital_objects.reject { |obj| ddr_url?(obj.href) }
  end

  # This count includes all descendant components' DAOs
  def total_digital_object_count
    first('total_digital_object_count_isim') || 0
  end

  # Several DUL-Custom DAO methods to determine the nature of
  # digital objects on a component or collection in order to
  # render the respective link or inline viewer.
  def single_dao?
    digital_objects.count == 1
  end

  def multiple_daos?
    digital_objects.count > 1
  end

  # Get an array of all unique @role values present in the set of DAOs.
  def dao_roles
    digital_objects.uniq(&:role).map { |dao| dao.role }
  end

  def dao_single_role
    return unless single_dao? && dao_roles.count == 1

    digital_objects.first.role
  end

  # For now, a DDR digital object is determined by an href attribute
  # pointing to the idn.duke.edu domain.
  def ddr_dao_count
    digital_objects.select { |obj| ddr_url?(obj.href) }.count
  rescue URI::InvalidURIError
    0
  end

  def multiple_ddr_daos?
    ddr_dao_count > 1
  end

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  private

  def ddr_url?(url)
    URI.parse(url).host == 'idn.duke.edu'
  end

  def stripped_snippets
    highlights&.map { |h| ActionController::Base.helpers.strip_tags(h).strip.squish }
  end

  def title_should_have_highlighting?
    highlight_index.present?
  end

  def highlight_index
    stripped_snippets&.find_index { |s| first('normalized_title_ssm').strip.squish.start_with?(s) }
  end
end
