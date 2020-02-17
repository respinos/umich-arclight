# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument
  include DulArclight
  require 'uri'

  # self.unique_key = 'id'

  def bibnum
    first('bibnum_ssi')
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
end
