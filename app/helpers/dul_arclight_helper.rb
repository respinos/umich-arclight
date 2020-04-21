# frozen_string_literal: true

# Helper methods specific to DUL ArcLight
# ---------------------------------------
module DulArclightHelper
  ##
  # @param [SolrDocument]
  def collection_doc(document)
    SolrDocument.find(normalize_id(document.eadid))
  end

  # Model DUL breadcrumb trails after regular_compact_breadcrumbs(), but with these changes:
  # 1) remove repository link; 2) include the top-level series
  # https://github.com/projectblacklight/arclight/blob/master/app/helpers/arclight_helper.rb#L30-L52

  def dul_compact_breadcrumbs(document)
    breadcrumb_links = []
    parents = document_parents(document)
    breadcrumb_links << parents[0, 2].map do |parent|
      link_to parent.label, solr_document_path(parent.global_id)
    end

    breadcrumb_links << '&hellip;'.html_safe if parents.length > 1

    safe_join(
      breadcrumb_links,
      aria_hidden_breadcrumb_separator
    )
  end
end
