# frozen_string_literal: true

CUSTOM_DAO_ROLES = %w[
  audio-streaming
  electronic-record-master
  electronic-record-use-copy
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
  def render_object_viewer(obj, doc = nil)
    if CUSTOM_DAO_ROLES.include? obj.role
      render partial: ['arclight/viewers/', obj.role].join, locals: { obj: obj, doc: doc }
    else
      render partial: 'arclight/viewers/web-resource-link', locals: { obj: obj, doc: doc }
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

  # Temporary link to an Aeon request using OpenURL
  # https://support.atlas-sys.com/hc/en-us/articles/360011919573-Submitting-Requests-via-OpenURL
  # NOTE: this is only used for legacy electronic record DAOs and is
  # likely a stopgap until those can be refactored or migrated elsewhere.
  def erec_aeon_link(obj, doc)
    base_url = 'https://duke.aeon.atlas-sys.com/logon/'
    [base_url, '?', aeon_params(obj, doc)].join
  end

  private

  def aeon_params(obj, doc)
    params_with_values =
      {
        'Action': '10',
        'Form': '30',
        'genre': 'manuscript',
        'rfe_dat': ['Aleph:', doc.bibnums&.first]&.join,
        "rft.access": doc.accessrestrict.map { |r| strip_tags(r) }&.join(' '),
        'rft.au': doc.creator,
        'rft.barcode': obj.xpointer,
        'rft.callnum': obj.role,
        'rft.collcode': 'Electronic_Record',
        'rft.date': doc.normalized_date,
        'rft.eadid': doc.eadid,
        'rft.pub': doc.id,
        'rft.site': 'SCL',
        'rft.stitle': [obj.label, doc.extent].join(' -- '),
        'rft.title': doc.collection_name,
        'rft.volume': obj.href
      }.reject { |_, v| v.blank? }
    params_with_values&.to_query
  end
end
