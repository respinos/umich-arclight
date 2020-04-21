# frozen_string_literal: true

require 'dul_arclight/digital_object'

class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument

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

  # DUL-specific language display logic: If there's at least one <langmaterial> with no
  # child <language>, use that/those. Fall back to using langmaterial/language values.
  def languages
    fetch('langmaterial_ssm') { fetch('language_ssm', []) }
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
    digital_objects.map { |obj| URI.parse(obj.href).host == 'idn.duke.edu' }.count
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
