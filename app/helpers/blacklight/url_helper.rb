# Extends Blacklight's Url helper to
# customize UMICH ArcLight. See:
# https://github.com/projectblacklight/blacklight/blob/master/app/helpers/blacklight/url_helper_behavior.rb
# ---------------------------------------

module Blacklight
  module UrlHelper
    include Blacklight::UrlHelperBehavior

    def link_to_document(doc, field_or_opts = nil, opts = { counter: nil }, url_options = { anchor: nil })
      label = case field_or_opts
              when NilClass
                document_presenter(doc).heading
              when Hash
                opts = field_or_opts
                document_presenter(doc).heading
              when Proc, Symbol
                Deprecation.warn(self, "passing a #{field_or_opts.class} to link_to_document is deprecated and will be removed in Blacklight 8")
                Deprecation.silence(Blacklight::IndexPresenter) do
                  index_presenter(doc).label field_or_opts, opts
                end
              else # String
                field_or_opts
              end

      Deprecation.silence(Blacklight::UrlHelperBehavior) do
        if url_for_document(doc) == doc && doc.is_a?(SolrDocument)
          link_to label, solr_document_path(doc, url_options), document_link_params(doc, opts)
        else
          link_to label, url_for_document(doc), document_link_params(doc, opts)
        end
      end
    end
  end
end
