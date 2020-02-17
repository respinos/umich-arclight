# frozen_string_literal: true

# Overrides ArcLight core digital object model. Capture the DAO @role
# attribute for custom behavior.
# Last checked for updates: ArcLight v0.3.0.
# https://github.com/projectblacklight/arclight/blob/master/lib/arclight/digital_object.rb

module DulArclight
  ##
  # Plain ruby class to model serializing/deserializing digital object data
  class DigitalObject
    attr_reader :label, :href, :role
    def initialize(label:, href:, role:)
      @label = label.present? ? label : href
      @href = href
      @role = role
    end

    def to_json(*)
      { label: label, href: href, role: role }.to_json
    end

    def self.from_json(json)
      object_data = JSON.parse(json)
      new(label: object_data['label'], href: object_data['href'], role: object_data['role'])
    end

    def ==(other)
      href == other.href && label == other.label && role == other.role
    end
  end
end
