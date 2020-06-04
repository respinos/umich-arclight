# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Search results', type: :feature do
  describe 'debug mode' do
    it 'does not display relevance score by default' do
      visit search_catalog_path q: 'duke', search_field: 'all_fields'
      expect(page).not_to have_css '.relevance-score'
    end

    it 'displays relevance score for each result with ?debug=true' do
      visit search_catalog_path q: 'duke', debug: true, search_field: 'all_fields'
      expect(page).to have_css '.relevance-score'
    end

    it 'displays relevance score in group view for each result with ?debug=true' do
      visit search_catalog_path q: 'duke', debug: true, group: true, search_field: 'all_fields'
      expect(page).to have_css '.relevance-score'
    end
  end
end
