# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection Page', type: :feature do
  xdescribe 'UA collection' do
    let(:doc_id) { 'uaduketaekwondo' }

    before do
      visit solr_document_path(id: doc_id)
    end

    it 'looks up UA record group titles and links to the facet' do
      expect(page).to have_link('31 — Student/Campus Life',
                                href: '/?f%5Bua_record_group_ssim%5D%5B%5D=31')
      expect(page).to have_link('11 — Student Organizations - Recreational Sports',
                                href: '/?f%5Bua_record_group_ssim%5D%5B%5D=31%3A11')
    end
  end
end
