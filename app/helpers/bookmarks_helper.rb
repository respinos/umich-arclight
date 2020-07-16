# frozen_string_literal: true

require 'csv'

# TODO: Consider if this logic belongs somewhere else
# that is not a helper.

# Helper methods to render Bookmarked items
# ----------------------------------------
module BookmarksHelper
  # Fields that we can't readily get from finding aid components, but
  # we still want blank columns created for them. This should help when
  # adding metadata for DDR ingest or doing batch metadata upload later.
  DDR_PLACEHOLDER_FIELDS = %w[
    display_format
    type
    format
    rights
    rights_note
    creator
    contributor
  ].freeze

  def bookmarks_csv_export
    CSV.generate do |csv|
      # NOTE: field headers are named carefully to optimize use of the CSV for
      # two purposes:
      # 1) a starter digitization guide for DPC
      # 2) a metadata CSV for ingest into DDR

      # Column Headers intentionally match what the DDR expects these fields to be called
      csv << csv_column_headers

      # Individual rows for each bookmark
      @response.documents.each do |doc|
        csv << [
          polymorphic_url(url_for_document(doc)),
          doc.collection_unitid,
          doc.eadid,
          doc.aspace_id,
          doc.level,
          strip_tags(doc.normalized_title),
          doc.normalized_date,
          doc.containers.join('|'),
          strip_tags(doc.abstract_or_scope),
          doc.physdesc.join('|'),
          doc.series_title,
          doc.subseries_title,
          meta_tag_description_context(doc) # breadcrumb
        ]
      end
    end
  end

  def bookmarks_csv_filename
    ['bookmarks-', DateTime.now.strftime('%Y%m%d'), '.csv'].join
  end

  private

  def csv_column_headers
    [
      'url',            # not in DDR
      'collection_id',  # not in DDR
      'ead_id',
      'aspace_id',
      'level',          # not in DDR
      'title',
      'date',
      'containers',
      'description',
      'extent',
      'series',
      'subseries',
      'breadcrumb'      # not in DDR
    ].concat(DDR_PLACEHOLDER_FIELDS)
  end
end
