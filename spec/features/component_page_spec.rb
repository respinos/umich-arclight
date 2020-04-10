# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Component Page', type: :feature do
  # Note the DUL-custom {eadid}_{ref} in the document id
  # This component is a series.
  let(:doc_id) { 'rushbenjaminandjulia_aspace_60bc65ac982c71ade8c13641188f6dbc' }

  before do
    visit solr_document_path(id: doc_id)
  end

  describe 'page layout' do
    it 'shows collection name above breadcrumb' do
      expect(page).to have_css('.collection-name', text: /Benjamin and Julia Stockton Rush papers/)
    end

    it 'has component title in an h1' do
      expect(page).to have_css('h1', text: /Letters, 1777-1824/)
    end
  end
end
