# frozen_string_literal: true

# Modifies some ArcLight core methods to account for the
# DUL custom child_components view. Last checked for updates
# ArcLight v0.3.0. See:
# https://github.com/projectblacklight/arclight/blob/master/app/models/concerns/arclight/catalog.rb
#
module DulArclight
  ##
  # DUL-ArcLight specific methods for the Catalog Controller
  module Catalog
    extend ActiveSupport::Concern
    include Arclight::Catalog

    # DUL CUSTOMIZATION: send the source EAD XML file that we already have on the filesystem
    # Modeled after "raw", see:
    # https://github.com/projectblacklight/blacklight/blob/master/app/controllers/concerns/blacklight/catalog.rb#L65-L71
    def ead_download
      _, @document = search_service.fetch(params[:id])
      send_file(
        ead_file_path,
        filename: "#{params[:id]}.xml",
        disposition: 'inline',
        type: 'text/xml'
      )
    end

    def html_download
      _, @document = search_service.fetch(params[:id])
      render file: html_file_path, layout: false
    end

    def pdf_download
      _, @document = search_service.fetch(params[:id])
      send_file(
        pdf_file_path,
        filename: "#{params[:id]}.pdf",
        disposition: 'attachment',
        type: 'application/pdf'
      )
    end

    ##
    # Overriding the Blacklight method so that the hierarchy view does not start
    # a new search session
    def start_new_search_session?
      !%w[online_contents collection_context child_components].include?(params[:view]) && super
    end

    ##
    # Overriding the Blacklight method so that hierarchy does not get stored as
    # the preferred view
    def store_preferred_view
      return if %w[online_contents collection_context child_components].include?(params[:view])

      super
    end

    private

    def ead_file_path
      "#{DulArclight.finding_aid_data}/ead/#{repo_id}/#{params[:id]}.xml"
    end

    def html_file_path
      "#{DulArclight.finding_aid_data}/pdf/#{repo_id}/#{params[:id]}.html"
    end

    def pdf_file_path
      "#{DulArclight.finding_aid_data}/pdf/#{repo_id}/#{params[:id]}.pdf"
    end

    def repo_id
      @document.repository_config&.slug
    end
  end
end
