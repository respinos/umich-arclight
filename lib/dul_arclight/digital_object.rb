# frozen_string_literal: true

# Overrides ArcLight core digital object model. Capture the DAO @role
# and @xpointer attributes for custom behavior.
# Last checked for updates: ArcLight v0.3.0.
# https://github.com/projectblacklight/arclight/blob/master/lib/arclight/digital_object.rb

module DulArclight
  ##
  # Plain ruby class to model serializing/deserializing digital object data
  class DigitalObject
    attr_reader :label, :href, :role, :xpointer
    def initialize(label:, href:, role:, xpointer:)
      @label = label.present? ? label : href
      @href = href
      @role = role
      @xpointer = xpointer
    end

    def to_json(*)
      { label: label, href: href, role: role, xpointer: xpointer }.to_json
    end

    def self.from_json(json)
      object_data = JSON.parse(json)
      new(label: object_data['label'],
          href: object_data['href'],
          role: object_data['role'],
          xpointer: object_data['xpointer'])
    end

    def ==(other)
      href == other.href && label == other.label && role == other.role && xpointer == other.xpointer
    end
  end
end
