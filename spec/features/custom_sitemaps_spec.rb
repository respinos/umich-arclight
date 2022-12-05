# frozen_string_literal: true

require 'rails_spec_helper'

RSpec.xdescribe 'Custom sitemap', type: :feature do
  context 'with a URL for a configured query-based sitemap' do
    it 'returns a sitemaps.org compliant sitemap w/matching collection URLs & lastmod dates' do
      visit '/custom_sitemaps/nlm_history_of_medicine.xml'
      xml = page.body
      expect(xml).to match(/<\?xml version="1.0"/)
      expect(xml).to match(%r{catalog/trent-pasteurlouispapers</loc>})
      expect(xml).to match(/<lastmod>/)
    end
  end
end
