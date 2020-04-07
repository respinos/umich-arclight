# frozen_string_literal: true

# Adapted from ArcLight core spec. See:
# https://github.com/projectblacklight/arclight/blob/master/spec/features/traject/ead2_indexing_spec.rb

require 'spec_helper'

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
end
