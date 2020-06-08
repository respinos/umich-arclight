# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Digital Objects', type: :feature do
  before { visit solr_document_path(id: doc_id) }

  describe 'single DAO on a component' do
    context 'when DDR image (image-service)' do
      let(:doc_id) { 'daotest_aspace_testdao01' }

      it 'renders an iframe for the embedded image' do
        expect(page).to have_css('iframe.ddr-image-service')
      end
    end

    context 'when DDR video (video-streaming)' do
      let(:doc_id) { 'daotest_aspace_testdao02' }

      it 'renders an iframe for the embedded video' do
        expect(page).to have_css('iframe.ddr-video-streaming')
      end
    end

    context 'when DDR audio (audio-streaming)' do
      let(:doc_id) { 'daotest_aspace_testdao03' }

      it 'renders an iframe for the embedded audio' do
        expect(page).to have_css('iframe.ddr-audio-streaming')
      end
    end

    context 'when Web archive (web-archive)' do
      let(:doc_id) { 'daotest_aspace_testdao04' }

      it 'renders a link with the title' do
        expect(page).to have_link('View Web Archive')
        expect(page).to have_css('span', text: 'ACLU of North Carolina website')
      end
    end

    context 'when Web link (web-resource-link)' do
      let(:doc_id) { 'daotest_aspace_testdao05' }

      it 'renders a link with the title' do
        expect(page).to have_link('View')
        expect(page).to have_css('span', text: 'A test title of a web-resource-link DAO')
      end
    end

    context 'when generic default DAO' do
      let(:doc_id) { 'daotest_aspace_testdao06' }

      it 'renders a link with the title' do
        expect(page).to have_link('View')
        expect(page).to have_css('span', text: 'A test title of a generic DAO')
      end
    end
  end

  describe 'multiple DAOs on a component' do
    context 'when multiple non-DDR DAOs' do
      let(:doc_id) { 'daotest_aspace_testdao10' }

      it 'renders links to each, with titles' do
        expect(page).to have_css('a', text: 'View', count: 3)
        expect(page).to have_css('span', text: 'Duke University Web Directory 1')
        expect(page).to have_css('span', text: 'Duke University Web Directory 2')
        expect(page).to have_css('span', text: 'Duke University Web Directory 3')
      end
    end

    context 'when multiple DDR image (image-service) DAOs' do
      let(:doc_id) { 'daotest_aspace_testdao11' }

      it 'renders a link to the DDR faceted on ead_id & aspace_id instead of embedding' do
        expect(page).not_to have_css('iframe')
        expect(page).to \
          have_link('View 2 items',
                    href: 'https://repository.duke.edu/catalog?f%5Bead_id_ssi%5D%5B%5D=daotest&f%5Baspace_id_ssi%5D%5B%5D=testdao11')
        expect(page).to have_css('span', text: '(Duke Digital Repository)')
      end
    end

    context 'when one DDR DAO plus one non-DDR DAO' do
      let(:doc_id) { 'daotest_aspace_testdao12' }

      it 'renders an iframe for the DDR embedded object' do
        expect(page).to have_css('iframe.ddr-audio-streaming')
      end

      it 'still renders a link to the non-DDR DAO' do
        expect(page).to have_link('View')
        expect(page).to have_css('span', text: 'A test title of a generic DAO')
      end
    end

    context 'when mix of multiple DDR & non-DDR DAOs' do
      let(:doc_id) { 'daotest_aspace_testdao13' }

      it 'renders a link to the DDR faceted on ead_id & aspace_id instead of embedding' do
        expect(page).not_to have_css('iframe')
        expect(page).to \
          have_link('View 2 items',
                    href: 'https://repository.duke.edu/catalog?f%5Bead_id_ssi%5D%5B%5D=daotest&f%5Baspace_id_ssi%5D%5B%5D=testdao13')
        expect(page).to have_css('span', text: '(Duke Digital Repository)')
      end

      it 'still renders the non-DDR DAOs' do
        expect(page).to have_link('View')
        expect(page).to have_link('View')
        expect(page).to have_css('span', text: 'A test title of a generic DAO')
      end
    end
  end
end
