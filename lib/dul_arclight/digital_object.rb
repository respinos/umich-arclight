# frozen_string_literal: true

# Overrides ArcLight core digital object model. Capture the DAO @role
# and @xpointer attributes for custom behavior.
# Last checked for updates: ArcLight v0.3.0.
# https://github.com/projectblacklight/arclight/blob/master/lib/arclight/digital_object.rb

require 'uri'

module DulArclight
  ##
  # Plain ruby class to model serializing/deserializing digital object data
  class DigitalObject
    attr_reader :label, :href, :role, :xpointer, :embed_data
    def initialize(label:, href:, role:, xpointer:)
      @label = label.present? ? label : href
      @href = href
      @role = role
      @xpointer = xpointer

      guess_role
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

    def iframe_link(doc)
      return @href if @embed_data.nil?

      repository = doc.repository_config
      case @role
      when 'image-service'
        repository.image_service(@embed_data)
      when 'video-streaming'
        repository.video_service(@embed_data)
      end
    end

    def guess_role
      uri = URI(@href)
      if match = uri.path.match('/[a-z]/([^/]+)/([^/]+)/(\w+)$')
        @embed_data = {
          identifier: "#{match[1]}:#{match[2]}:#{match[3]}",
          collid: match[1],
          hostname: uri.hostname
        }
        @role = 'image-service'
      elsif uri.hostname.match('.mivideo.')
        @embed_data = {
          repository: uri.hostname.split('.').first,
          entry_id: uri.path.split('/').last
        }
        @role = 'video-streaming'
      end
    end
  end
end
