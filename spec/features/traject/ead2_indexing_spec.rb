# frozen_string_literal: true

# Adapted from ArcLight core spec. See:
# https://github.com/projectblacklight/arclight/blob/master/spec/features/traject/ead2_indexing_spec.rb

require 'rails_spec_helper'
require 'nokogiri'

RSpec.describe 'EAD 2 traject indexing', type: :feature do
  subject(:result) do
    indexer.map_record(record)
  end

  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('lib', 'dul_arclight', 'traject', 'ead2_config.rb'))
    end
  end

  let(:fixture_path) do
    Rails.root.join('spec', 'fixtures', 'ead', 'rubenstein', 'rushbenjaminandjulia.xml')
  end

  let(:fixture_file) do
    File.read(fixture_path)
  end

  let(:nokogiri_reader) do
    DulArclight::Traject::DulCompressedReader.new(fixture_file.to_s, indexer.settings)
  end

  let(:records) do
    nokogiri_reader.to_a
  end

  let(:record) do
    records.first
  end

  before do
    ENV['REPOSITORY_ID'] = nil
  end

  after do # ensure we reset these otherwise other tests will fail
    ENV['REPOSITORY_ID'] = nil
  end

  describe 'DUL basic indexing customizations' do
    describe 'component ids for custom URLs' do
      let(:first_component) { result['components'].first }

      it 'creates id with eadid & ref separated by underscore' do
        expect(first_component).to include 'id' => [
          'rushbenjaminandjulia_aspace_60bc65ac982c71ade8c13641188f6dbc'
        ]
      end
    end

    describe 'Bib number indexing' do
      describe 'collection level' do
        it 'gets bib number' do
          expect(result['bibnum_ssim'].first).to eq '002164677'
        end
      end

      describe 'component level' do
        it 'gets bib number from collection / top level' do
          component = result['components'].find { |c| c['id'] == ['rushbenjaminandjulia_aspace_60bc65ac982c71ade8c13641188f6dbc'] }
          expect(component).to include 'bibnum_ssim'
          expect(component['bibnum_ssim'].first).to eq '002164677'
        end
      end
    end

    describe 'UA record groups for non-UA collections' do
      it 'skips record groups unless archdesc/did/unitid begins with UA.' do
        expect(result['ua_record_group_ssim']).to be_nil
      end
    end
  end

  describe 'UA collection indexing' do
    let(:fixture_path) do
      Rails.root.join('spec', 'fixtures', 'ead', 'ua', 'uaduketaekwondo.xml')
    end

    describe 'UA record groups' do
      it 'captures the top level group' do
        expect(result['ua_record_group_ssim']).to include('31')
      end

      it 'captures the sub group preceded by its parent group' do
        expect(result['ua_record_group_ssim']).to include('31:11')
      end
    end
  end

  describe 'restrictions inheritance & indexing' do
    let(:fixture_path) do
      Rails.root.join('spec', 'fixtures', 'ead', 'rubenstein', 'restrictionstest.xml')
    end

    describe 'series with own restrictions' do
      it 'gets its own restrictions' do
        component = result['components'].find { |c| c['id'] == ['restrictionstest_aspace_testrestrict_series_a'] }
        expect(component['accessrestrict_tesim'].count).to eq 1
        expect(component['accessrestrict_tesim'].first.to_xml).to eq '<p>Access Restriction A</p>'
        expect(component['phystech_tesim'].count).to eq 1
        expect(component['phystech_tesim'].first.to_xml).to eq '<p>Phystech Restriction A</p>'
      end
    end

    describe 'series without restrictions' do
      it 'gets no restrictions, not even from top-level archdesc' do
        component = result['components'].find { |c| c['id'] == ['restrictionstest_aspace_testrestrict_series_b'] }
        expect(component['accessrestrict_tesim']).to be nil
        expect(component['userestrict_tesim']).to be nil
        expect(component['phystech_tesim']).to be nil
      end
    end

    describe 'subseries with restrictions under a restricted series' do
      it 'gets only its own restrictions, not from its parent series' do
        component = result['components'].find { |c| c['id'] == ['restrictionstest_aspace_testrestrict_subseries_c'] }
        expect(component['accessrestrict_tesim'].count).to eq 1
        expect(component['accessrestrict_tesim'].first.to_xml).to eq '<p>Access Restriction C</p>'
        expect(component['phystech_tesim'].count).to eq 1
        expect(component['phystech_tesim'].first.to_xml).to eq '<p>Phystech Restriction C</p>'
      end
    end

    describe 'subseries without restrictions under a restricted series' do
      it 'gets restrictions from its parent series' do
        component = result['components'].find { |c| c['id'] == ['restrictionstest_aspace_testrestrict_subseries_d'] }
        expect(component['accessrestrict_tesim'].count).to eq 1
        expect(component['accessrestrict_tesim'].first.to_xml).to eq '<p>Access Restriction A</p>'
        expect(component['userestrict_tesim'].count).to eq 1
        expect(component['userestrict_tesim'].first.to_xml).to eq '<p>Use Restriction A</p>'
        expect(component['phystech_tesim'].count).to eq 1
        expect(component['phystech_tesim'].first.to_xml).to eq '<p>Phystech Restriction A</p>'
      end
    end

    describe 'subseries without restrictions, under a series without restrictions' do
      it 'gets no restrictions, not even from top-level archdesc' do
        component = result['components'].find { |c| c['id'] == ['restrictionstest_aspace_testrestrict_subseries_f'] }
        expect(component['accessrestrict_tesim']).to be nil
        expect(component['userestrict_tesim']).to be nil
        expect(component['phystech_tesim']).to be nil
      end
    end

    describe 'file with restrictions under a restricted subseries' do
      it 'gets only its own restrictions, not from its parent subseries nor its ancestor series' do
        component = result['components'].find { |c| c['id'] == ['restrictionstest_aspace_testrestrict_file_h'] }
        expect(component['accessrestrict_tesim'].count).to eq 1
        expect(component['accessrestrict_tesim'].first.to_xml).to eq '<p>Access Restriction H</p>'
        expect(component['phystech_tesim'].count).to eq 1
        expect(component['phystech_tesim'].first.to_xml).to eq '<p>Phystech Restriction H</p>'
      end
    end

    describe 'file without restrictions 2 deep under a restricted series' do
      it 'gets restrictions from its grandparent series' do
        component = result['components'].find { |c| c['id'] == ['restrictionstest_aspace_testrestrict_file_i'] }
        expect(component['accessrestrict_tesim'].count).to eq 1
        expect(component['accessrestrict_tesim'].first.to_xml).to eq '<p>Access Restriction A</p>'
        expect(component['phystech_tesim'].count).to eq 1
        expect(component['phystech_tesim'].first.to_xml).to eq '<p>Phystech Restriction A</p>'
      end
    end
  end
end
