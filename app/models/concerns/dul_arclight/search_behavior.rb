# frozen_string_literal: true

# Modifies some ArcLight core methods to account for the
# DUL custom child_components view. Last checked for updates
# ArcLight v0.3.0. See:
# https://github.com/projectblacklight/arclight/blob/master/app/models/concerns/arclight/search_behavior.rb
#
module DulArclight
  ##
  # Customized Search Behavior for DUL-Arclight
  module SearchBehavior
    extend ActiveSupport::Concern
    extend Arclight::SearchBehavior

    included do
      self.default_processor_chain += [:add_solr_debug]
    end

    ##
    # Override Blacklight's method so that some views don't add Solr facets into the request.
    def add_facetting_to_solr(solr_params)
      return solr_params if %w[collection_context online_contents child_components].include? blacklight_params[:view]

      super(solr_params)
    end

    ##
    # For the collection_context views, set a higher (unlimited) maximum document return
    def add_hierarchy_max_rows(solr_params)
      solr_params[:rows] = 999_999_999 if %w[collection_context].include? blacklight_params[:view]
      solr_params[:rows] = 999_999_999 if %w[expanded_child_components].include? blacklight_params[:view]

      # For inline child components display on component view, break into pages of 100.
      # This has to be in sync with collection_navigation.js
      solr_params[:rows] = 100 if %w[child_components].include? blacklight_params[:view]

      solr_params
    end

    ##
    # For the asynch views, set the sort order to preserve the order of components
    def add_hierarchy_sort(solr_params)
      solr_params[:sort] = 'sort_ii asc' if %w[online_contents collection_context child_components].include? blacklight_params[:view]
      solr_params
    end

    # Debug mode includes relevance score and Solr links when using ?debug=true
    # Inspired by:
    # https://github.com/trln/trln_argon/blob/master/lib/trln_argon/argon_search_builder/add_solr_debug_info.rb
    def add_solr_debug(solr_params)
      # NOTE: parent:[subquery] part is necessary for Group By collection queries.
      #       The score is not returned by default in grouped queries
      solr_params.merge!(fl: '*,score,parent:[subquery]') if blacklight_params[:debug] == 'true'

      solr_params
    end
  end
end
