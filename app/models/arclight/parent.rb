# frozen_string_literal: true

# Complete overwrite of ArcLight class to account for the
# DUL custom underscore in a component doc id. Last checked for updates
# ArcLight v0.3.0. See:
# https://github.com/projectblacklight/arclight/blob/master/app/models/arclight/parent.rb
#

module Arclight
  # Override ArcLight core
  class Parent
    attr_reader :id, :label, :eadid, :level
    def initialize(id:, label:, eadid:, level:)
      @id = id
      @label = label
      @eadid = eadid
      @level = level
    end

    ## DUL Customization: add an underscore between eadid & id
    ##
    # Concatenates the eadid and the id, to return an "id" in the context of
    # Blacklight and Solr
    # @return [String]
    def global_id
      return id if eadid == id

      "#{eadid}_#{id}"
    end
  end
end
