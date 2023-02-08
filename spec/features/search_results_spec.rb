# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search results', type: :feature do
  describe 'debug mode' do
    it 'does not display relevance score by default' do
      visit search_catalog_path q: 'duke', search_field: 'all_fields'
      expect(page).not_to have_css '.relevance-score'
    end

    xit 'displays relevance score for each result with ?debug=true' do
      visit search_catalog_path q: 'duke', debug: true, search_field: 'all_fields'
      expect(page).to have_css '.relevance-score'
    end

    xit 'displays relevance score in group view for each result with ?debug=true' do
      visit search_catalog_path q: 'duke', debug: true, group: true, search_field: 'all_fields'
      expect(page).to have_css '.relevance-score'
    end
  end

  xit 'pluralizes multivalued facet names' do # rubocop:disable RSpec/ExampleLength
    visit search_catalog_path q: '', search_field: 'all_fields'

    within('#facets') do
      within('.blacklight-names_ssim') do
        expect(page).to have_css('h3 button', text: 'Names')
      end
      within('.blacklight-places_ssim') do
        expect(page).to have_css('h3 button', text: 'Places')
      end
      within('.blacklight-access_subjects_ssim') do
        expect(page).to have_css('h3 button', text: 'Subjects')
      end
      within('.blacklight-formats_ssim') do
        expect(page).to have_css('h3 button', text: 'Formats')
      end
    end
  end
end
