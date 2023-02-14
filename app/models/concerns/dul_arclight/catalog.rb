# frozen_string_literal: true

require 'um_arclight/download_helper'

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

    included do
      if respond_to?(:before_action)
        before_action :setup_download_helper, only: [:ead_download, :html_download, :pdf_download]
      end

      if respond_to?(:helper_method)
        helper_method :pdf_available?
        helper_method :ead_available?
      end

      if respond_to?(:after_action)
        after_action :add_noindex_headers
      end
    end

    # DUL CUSTOMIZATION: send the source EAD XML file that we already have on the filesystem
    # Modeled after "raw", see:
    # https://github.com/projectblacklight/blacklight/blob/master/app/controllers/concerns/blacklight/catalog.rb#L65-L71
    def ead_download
      xml_filename = download_helper.ead_file_path

      unless xml_filename && File.exist?(xml_filename)
        render plain: '404 Not Found', status: :not_found
        return
      end

      send_file(
        xml_filename,
        filename: "#{@document.id}.xml",
        disposition: 'inline',
        type: 'text/xml'
      )
    end

    def html_download
      _, @document = search_service.fetch(params[:id])

      headers['Content-Type'] = 'text/html'
      headers['X-Accel-Buffering'] = 'no' # Stop NGINX from buffering
      headers.delete('Content-Length')
      headers.delete('ETag')

      # replace m-arclight-placeholder with current asset styles/scripts
      self.response_body = Enumerator.new do |output|
        File.foreach(download_helper.html_file_path) do |line|
          if line.index('<base id="placeholder">')
            output << helpers.stylesheet_link_tag('application', media: 'all')
            output << helpers.javascript_include_tag('application')
            output << helpers.csrf_meta_tags
            next
          end
          output << line
        end
      end
    end

    def pdf_download
      send_file(
        download_helper.pdf_file_path,
        filename: "#{@document.id}.pdf",
        disposition: 'attachment',
        type: 'application/pdf'
      )
    end

    def pdf_available?
      setup_download_helper
      download_helper.pdf_available?
    end

    def ead_available?(document)
      setup_download_helper
      download_helper.ead_available?
    end

    def add_noindex_headers
      unless params[:id]
        response.headers['X-Robots-Tag'] = 'noindex'
      end
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

    def setup_download_helper
      _, @document = search_service.fetch(params[:id])
      @download_helper = UmArclight::DownloadHelper.new(@document)
    end

    def download_helper
      @download_helper
    end
  end
end
