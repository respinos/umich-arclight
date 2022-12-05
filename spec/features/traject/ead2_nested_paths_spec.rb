# frozen_string_literal: true

# Adapted from ArcLight core spec. See:
# https://github.com/projectblacklight/arclight/blob/master/spec/features/traject/ead2_indexing_spec.rb

require 'spec_helper'
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
    Rails.root.join('spec', 'fixtures', 'ead', 'test', 'test-nested-paths.xml')
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

  describe 'descgrp nested paths' do
    describe 'bibliography paths' do
      it 'descgrp-bibliography-head-text' do
        expect(result['bibliography_heading_ssm'].join("")).to include 'descgrp-bibliography-head-text'
      end

      it 'descgrp-bibliography-list-head-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-list-head-text'
      end

      it 'descgrp-bibliography-list-item-title-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-list-item-title-text'
      end

      it 'descgrp-bibliography-list-item-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-list-item-text'
      end

      it 'descgrp-bibliography-p-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-text'
      end

      it 'descgrp-bibliography-p-list-item-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-list-item-text'
      end

      it 'descgrp-bibliography-p-list-item-list-item-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-list-item-list-item-text'
      end

      it 'descgrp-bibliography-p-list-item-title-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-list-item-title-text'
      end

      it 'descgrp-bibliography-p-title-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-title-text'
      end

      it 'descgrp-bibliography-p-emph-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-emph-text'
      end

      it 'descgrp-bibliography-p-list-head-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-list-head-text'
      end

      it 'descgrp-bibliography-p-note-p-text' do
        expect(result['bibliography_teim'].join("")).to include 'descgrp-bibliography-p-note-p-text'
      end
    end


    describe 'chronlist paths' do
      it 'descgrp-chronlist-head-text' do
        expect(result['chronlist_heading_ssm'].join("")).to include 'descgrp-chronlist-head-text'
      end

      it 'descgrp-chronlist-chronitem-date-text' do
        expect(result['chronlist_teim'].join("")).to include 'descgrp-chronlist-chronitem-date-text'
      end

      it 'descgrp-chronlist-chronitem-event-title-text' do
        expect(result['chronlist_teim'].join("")).to include 'descgrp-chronlist-chronitem-event-title-text'
      end
      it 'descgrp-chronlist-chronitem-event-text' do
        expect(result['chronlist_teim'].join("")).to include 'descgrp-chronlist-chronitem-event-text'
      end
    end

    describe 'index_paths' do

      it 'descgrp-index-head-text' do
        expect(result['index_heading_ssm'].join("")).to include 'descgrp-index-head-text'
      end
      it 'descgrp-index-head-emph-text' do
        expect(result['index_heading_ssm'].join("")).to include 'descgrp-index-head-emph-text'
      end
      it 'descgrp-index-head-emph-emph-text' do
        expect(result['index_heading_ssm'].join("")).to include 'descgrp-index-head-emph-emph-text'
      end
      it 'descgrp-index-head-emph-emph-emph-text' do
        expect(result['index_heading_ssm'].join("")).to include 'descgrp-index-head-emph-emph-emph-text'
      end


      it 'descgrp-index-index-head-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-index-head-text'
      end

      it 'descgrp-index-index-indexentry-corpname-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-index-indexentry-corpname-text'
      end


      it 'descgrp-index-index-indexentry-persname-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-index-indexentry-persname-text'
      end
      it 'descgrp-index-index-indexentry-ref-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-index-indexentry-ref-text'
      end
      it 'descgrp-index-index-indexentry-ref-list-item-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-index-indexentry-ref-list-item-text'
      end


      it 'descgrp-index-p-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-p-text'
      end

      it 'descgrp-index-indexentry-corpname-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-corpname-text'
      end


      it 'descgrp-index-indexentry-famname-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-famname-text'
      end


      it 'descgrp-index-indexentry-genreform-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-genreform-text'
      end


      it 'descgrp-index-indexentry-geogname-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-geogname-text'
      end


      it 'descgrp-index-indexentry-occupation-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-occupation-text'
      end


      it 'descgrp-index-indexentry-persname-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-persname-text'
      end
      it 'descgrp-index-indexentry-ref-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-ref-text'
      end
      it 'descgrp-index-indexentry-ref-list-item-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-ref-list-item-text'
      end


      it 'descgrp-index-indexentry-ref-note-p-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-ref-note-p-text'
      end


      it 'descgrp-index-indexentry-subject-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-subject-text'
      end


      it 'descgrp-index-indexentry-title-text' do
        expect(result['index_teim'].join("")).to include 'descgrp-index-indexentry-title-text'
      end
    end

    describe 'list paths'
    it 'descgrp-list-head-text' do
      expect(result['list_heading_ssm'].join("")).to include 'descgrp-list-head-text'
    end
    it 'descgrp-list-head-emph-text' do
      expect(result['list_heading_ssm'].join("")).to include 'descgrp-list-head-emph-text'
    end

    it 'descgrp-list-item-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-text'
    end

    it 'descgrp-list-item-blockquote-p-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-blockquote-p-text'
    end

    it 'descgrp-list-item-blockquote-p-emph-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-blockquote-p-emph-text'
    end


    it 'descgrp-list-item-emph-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-emph-text'
    end
    it 'descgrp-list-item-geogname-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-geogname-text'
    end

    it 'descgrp-list-item-list-head-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-list-head-text'
    end
    it 'descgrp-list-item-list-item-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-list-item-text'
    end
    it 'descgrp-list-item-list-item-emph-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-list-item-emph-text'
    end


    it 'descgrp-list-item-list-item-list-head-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-list-item-list-head-text'
    end


    it 'descgrp-list-item-list-item-list-item-list-item-list-item-list-item-list-item-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-list-item-list-item-list-item-list-item-list-item-list-item-text'
    end


    it 'descgrp-list-item-list-item-list-item-persname-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-list-item-list-item-persname-text'
    end


    it 'descgrp-list-item-list-item-persname-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-list-item-persname-text'
    end


    it 'descgrp-list-item-note-p-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-note-p-text'
    end
    it 'descgrp-list-item-note-p-emph-text' do
      expect(result['list_teim'].join("")).to include 'descgrp-list-item-note-p-emph-text'
    end
  end

  describe 'odd paths' do
    it 'descgrp-odd-head-text' do
      expect(result['odd_heading_ssm'].join("")).to include 'descgrp-odd-head-text'
    end


    it 'descgrp-odd-chronlist-chronitem-date-text' do
      expect(result['odd_teim'].join("")).to include 'descgrp-odd-chronlist-chronitem-date-text'
    end

    it 'descgrp-odd-chronlist-chronitem-eventgrp-event-text' do
      expect(result['odd_teim'].join("")).to include 'descgrp-odd-chronlist-chronitem-eventgrp-event-text'
    end


    it 'descgrp-odd-list-item-archref-unittitle-geogname-text' do
      expect(result['odd_teim'].join("")).to include 'descgrp-odd-list-item-archref-unittitle-geogname-text'
    end


    it 'descgrp-odd-list-item-archref-physdesc-dimensions-text' do
      expect(result['odd_teim'].join("")).to include 'descgrp-odd-list-item-archref-physdesc-dimensions-text'
    end


    it 'descgrp-odd-p-text' do
      expect(result['odd_teim'].join("")).to include 'descgrp-odd-p-text'
    end
  end

  describe 'para (p) paths' do
    it 'descgrp-p-text' do
      expect(result['para_teim'].join("")).to include 'descgrp-p-text'
    end
  end

  describe 'related material paths' do
    it 'descgrp-relatedmaterial-head-text' do
      expect(result['relatedmaterial_heading_ssm'].join("")).to include 'descgrp-relatedmaterial-head-text'
    end

    it 'descgrp-relatedmaterial-p-text' do
      expect(result['relatedmaterial_teim'].join("")).to include 'descgrp-relatedmaterial-p-text'
    end

    it 'descgrp-relatedmaterial-p-list-item-text' do
      expect(result['relatedmaterial_teim'].join("")).to include 'descgrp-relatedmaterial-p-list-item-text'
    end

    it 'descgrp-relatedmaterial-p-extref-text' do
      expect(result['relatedmaterial_teim'].join("")).to include 'descgrp-relatedmaterial-p-extref-text'
    end

    it 'descgrp-relatedmaterial-p-archref-unittitle-text' do
      expect(result['relatedmaterial_teim'].join("")).to include 'descgrp-relatedmaterial-p-archref-unittitle-text'
    end

    it 'descgrp-relatedmaterial-p-archref-origination-persname-text' do
      expect(result['relatedmaterial_teim'].join("")).to include 'descgrp-relatedmaterial-p-archref-origination-persname-text'
    end


    it 'descgrp-relatedmaterial-p-bibref-text' do
      expect(result['relatedmaterial_teim'].join("")).to include 'descgrp-relatedmaterial-p-bibref-text'
    end
    it 'descgrp-relatedmaterial-p-bibref-imprint-date-text' do
      expect(result['relatedmaterial_teim'].join("")).to include 'descgrp-relatedmaterial-p-bibref-imprint-date-text'
    end

  end


  describe 'separatedmaterial paths' do
    it 'descgrp-separatedmaterial-head-text' do
      expect(result['separatedmaterial_heading_ssm'].join("")).to include 'descgrp-separatedmaterial-head-text'
    end

    it 'descgrp-separatedmaterial-list-item-text' do
      expect(result['separatedmaterial_teim'].join("")).to include 'descgrp-separatedmaterial-list-item-text'
    end


    it 'descgrp-separatedmaterial-note-p-text' do
      expect(result['separatedmaterial_teim'].join("")).to include 'descgrp-separatedmaterial-note-p-text'
    end

    it 'descgrp-separatedmaterial-p-text' do
      expect(result['separatedmaterial_teim'].join("")).to include 'descgrp-separatedmaterial-p-text'
    end

  end
end
