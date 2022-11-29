# frozen_string_literal: true

# Override config settings in
# https://github.com/projectblacklight/arclight/blob/master/lib/arclight/engine.rb

# Add DUL custom-created field accessors:
# indexes_field
# component_indexes_field
# restrictions_field
# component_restrictions_field
Arclight::Engine.config.catalog_controller_field_accessors = %i[
  summary_field
  access_field
  contact_field
  background_field
  related_field
  terms_field
  cite_field
  indexed_terms_field
  indexes_field
  in_person_field
  restrictions_field
  component_field
  online_field
  component_terms_field
  component_indexed_terms_field
  component_indexes_field
  component_restrictions_field
]
