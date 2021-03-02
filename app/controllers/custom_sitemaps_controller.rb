# frozen_string_literal: true

# Sitemap XML from a query (for targeted harvesters)
class CustomSitemapsController < ApplicationController
  def index
    docs = fetch_docs.dig(:response, :docs)
    render_sitemap(docs)
  end

  private

  def render_sitemap(docs)
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
        docs.each do |doc|
          xml.url do
            xml.loc absolute_url(doc.dig(:id))
            xml.lastmod doc.dig(:timestamp)
          end
        end
      end
    end
    render xml: builder.to_xml
  end

  def absolute_url(id)
    url_for(action: 'show', controller: 'catalog', id: id)
  end

  def fetch_docs
    search_service.search(
      'q': configured_query,
      'fq': 'level_sim:Collection',
      'fl': 'id, timestamp',
      'facet': 'false',
      'sort': 'timestamp desc',
      'rows': '50000'
      # Sitemaps cannot exceed 50,000 entries per sitemaps.org standard.
    )
  end

  def search_service
    Blacklight.repository_class.new(blacklight_config)
  end

  def configured_query
    CUSTOM_SITEMAP_CONFIG.dig(params[:id], 'query')
  end
end
