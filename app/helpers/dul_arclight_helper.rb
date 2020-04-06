# frozen_string_literal: true

# Helper methods specific to DUL ArcLight
# ---------------------------------------
module DulArclightHelper
  ##
  # @param [SolrDocument]
  def collection_doc(document)
    SolrDocument.find(normalize_id(document.eadid))
  end
end
