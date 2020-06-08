# frozen_string_literal: true

CUSTOM_DAO_ROLES = %w[
  audio-streaming
  image-service
  video-streaming
  web-archive
  web-resource-link
].freeze

# Helper methods for Digital Objects
# ---------------------------------------
module DigitalObjectHelper
  # Render a digital object link or inline player/viewer based on its role.
  # NOTE: we are not using the ArcLight core default viewer; we fall back to
  # our own web-resource-link viewer if no custom viewer is found.
  def render_object_viewer(obj)
    if CUSTOM_DAO_ROLES.include? obj.role
      render partial: ['arclight/viewers/', obj.role].join, locals: { obj: obj }
    else
      render partial: 'arclight/viewers/web-resource-link', locals: { obj: obj }
    end
  end

  # Link to a DDR search result (used with multiple DDR DAOs on a component)
  # Works with either EAD ID (esp. for collection-level DAOs) or component ID.
  def ddr_dao_search_result_link(document)
    ['https://repository.duke.edu/catalog?f%5Bead_id_ssi%5D%5B%5D=',
     document&.eadid,
     '&f%5Baspace_id_ssi%5D%5B%5D=',
     document&.reference&.sub('aspace_', '')].join
  end
end
