# frozen_string_literal: true

require 'dul_arclight/digital_object'
require_relative 'concerns/dul_arclight/solr_document'

class SolrDocument # rubocop:disable Metrics/ClassLength
  include Blacklight::Solr::Document
  include Arclight::SolrDocument
  include DulArclight::FieldConfigHelpers
  include ActionView::Helpers::TextHelper # for short description

  # DUL CUSTOMIZATION: map fields to generate the body of an email.
  # Borrowed from Blacklight core Blacklight::Solr::Document
  # https://github.com/projectblacklight/blacklight/blob/master/lib/generators/blacklight/templates/solr_document.rb#L7-L8
  SolrDocument.use_extension(Blacklight::Document::Email)

  # self.unique_key = 'id'

  # DUL CUSTOMIZATION: Capture last indexed date
  def last_indexed
    fetch('timestamp', '')
  end

  # DUL CUSTOMIZATION: Allow for formatting tags to render in collection/component
  # titles in some views.
  def normalized_title
    value = first('normalized_title_formatted_ssm') || first('normalized_title_ssm').to_s
    render_html_tags(value: [value]) if value.present?
  end

  def ead_author
    fetch('ead_author_ssm', []).first
  end

  def revdesc_changes
    fetch('revdesc_changes_ssm', []).map do |rev|
      JSON.parse(rev)
    end
  end

  # DUL CUSTOMIZATION: ARK & Permalink
  def ark
    fetch('ark_ssi', '')
  end

  def permalink
    fetch('permalink_ssi', '')
  end

  # DUL CUSTOMIZATION: get the non-prefixed ArchivesSpace ID for a component.
  # esp. for digitization guide / DDR import starter from bookmark export.
  def aspace_id
    fetch('ref_ssi', '').delete_prefix('aspace_')
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
  # Also include all values, not just the first abstract or scope. We also deduplicate the
  # values; we have many collections (esp. trent-*) with the same text in abstract & scopecontent.
  def abstract_or_scope
    abstracts = fetch('abstract_tesim', [])
    scopes = fetch('scopecontent_tesim', [])
    values = (abstracts + scopes).uniq { |v| ActionController::Base.helpers.strip_tags(v) }.join(' ')
    render_html_tags(value: [values]) if values.present?
  end

  def odd
    fetch('odd_tesim', [])
  end

  def bioghist
    fetch('bioghist_tesim', [])
  end

  # DUL custom property for a tagless short description of a collection or component.
  # Can be used e.g., in meta tags or popovers/tooltips.
  def short_description
    truncate(strip_tags(abstract_or_scope), length: 400, separator: ' ')
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

  # DUL override ArcLight core method; fall back to the ID if ref_ssm isn't present.
  # Currently only components get a ref_ssm.
  def reference
    first('ref_ssm') || fetch('id')
  end

  def component?
    parent_ids.present?
  end

  def parent_ids_keyed
    parent_ids.map do |parent_id|
      parent_id.gsub('.', '-')
    end
  end

  def accessrestrict
    fetch('accessrestrict_tesim', [])
  end

  def userestrict
    fetch('userestrict_tesim', [])
  end

  def phystech
    fetch('phystech_tesim', [])
  end

  def restricted_component?
    component? && (accessrestrict.present? || userestrict.present? || phystech.present?)
  end

  def total_component_count
    first('total_component_count_isim') || 0
  end

  def physdesc
    fetch('physdesc_tesim', []).map! { |value| correct_singular_value(value) }
  end

  def physloc
    fetch('collection_physloc_tesim', [])[0]
  end

  def collection_date
    fetch('collection_date_inclusive_ssm', [])[0]
  end

  def collection_creator
    fetch('collection_creator_ssm', [])[0]
  end

  def collection_has_requestable_components? # rubocop:disable Naming/PredicateName
    repository_config.request_config_present_for_type?('aeon_hidden_form_request')
  end

  def is_checkbox_requestable? # rubocop:disable Naming/PredicateName
    config_present = repository_config.request_config_present_for_type?('aeon_hidden_form_request')
    container_requestable = containers.all? do |container|
      %w[Box Folder Reel Map-case Tube Object Volume Bundle].any? do |type|
        container.match(/#{type}/)
      end
    end
    config_present && !containers.empty? && container_requestable
  end

  def is_linkable?
    (online_content? || number_of_children > 0)
  end

  # DUL override ArcLight core; we want all extent values, and to singularize e.g. 1 boxes.
  # document.extent is used for the "extent badge"; note other locations in the app use
  # the full physdesc field and may still be labeled as "Extent".
  def extent
    physdesc.join(' &mdash; ').html_safe if physdesc.present?
  end

  # Find the Series title by reconciling the arrays of parent labels & parent levels
  # NOTE: this method exists primarily for CSV exports of bookmarks for starter
  # digitization guides & batch metadata upload to DDR.
  def series_title
    i = parent_levels.find_index('Series')
    parent_labels[i] if i.present?
  end

  # Find the Subseries title by reconciling the arrays of parent labels & parent levels
  # NOTE: this method exists primarily for CSV exports of bookmarks for starter
  # digitization guides & batch metadata upload to DDR.
  def subseries_title
    i = parent_levels.find_index('Subseries')
    parent_labels[i] if i.present?
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
    highlights.delete_at(highlight_index) if highlight_index.present?
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

  def ddr_collection_objects
    digital_objects.select { |obj| obj.role == 'ddr-collection-object' }
  end

  # This count includes all descendant components' DAOs
  def total_digital_object_count
    first('total_digital_object_count_isim') || 0
  end

  # All unique values for @role in DAOs found anywhere in a collection
  def all_dao_roles
    fetch('all_dao_roles_ssim', [])
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
  # NOTE: only on this level, not descendants.
  def dao_roles
    digital_objects.uniq(&:role).map { |dao| dao.role }
  end

  def dao_single_role
    return unless single_dao? && dao_roles.count == 1

    digital_objects.first.role
  end

  # For now, a DDR digital object is determined by an href attribute
  # with hostname idn.duke.edu or repository.duke.edu & is not a collection.
  def ddr_dao_count
    all_ddr_daos = digital_objects.select { |obj| ddr_url?(obj.href) }
    all_ddr_daos.reject { |obj| ddr_collection_objects.include? obj }.count
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
    URI.parse(url).host.in? %w[idn.duke.edu repository.duke.edu]
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
