# frozen_string_literal: true

require 'spec_helper'

RSpec.xdescribe 'Component Page', type: :feature, js: true do
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

  describe 'ajax-loaded sidebar navigation' do
    it 'loads & highlights current component in sidebar' do
      expect(page).to have_css('li#nav_rushbenjaminandjulia_aspace_60bc65ac982c71ade8c13641188f6dbc.al-hierarchy-highlight')
    end

    it 'expands children upon +/- click' do
      find('#nav_rushbenjaminandjulia_aspace_3c7e06b31aff79e4b5b887524157f1fb a.al-toggle-view-children').click
      expect(page).to have_css('.document-title-heading a',
                               text: 'Benjamin Rush travel diary, 178[4] April 2-7')
    end
  end

  describe 'ajax-loaded child component navigation' do
    it 'renders child component section' do
      expect(page).to have_css('#documents.documents-child_components')
    end

    it 'renders pagination for 100+ child docs' do
      expect(page).to have_css('#sortAndPerPage')
    end

    it 'links to child components' do
      expect(page).to have_css('.document-title-heading a',
                               text: 'Abigail Adams (n.p.) letter to Julia Stockton Rush (Philadelphia), 1813 July 7')
    end
  end
end
