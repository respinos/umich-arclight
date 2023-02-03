# frozen_string_literal: true

# Extends ArcLight Core SolrDocument tests
# https://github.com/projectblacklight/arclight/blob/master/spec/models/concerns/arclight/solr_document_spec.rb
require 'spec_helper'

RSpec.describe SolrDocument do
  describe '#aspace_id' do
    let(:document) do
      described_class.new(
        ref_ssi: 'aspace_42ff52d27fd631ce27a32aee71f6114e'
      )
    end

    it 'gets the nonprefixed aspace id' do
      expect(document.aspace_id).to eq '42ff52d27fd631ce27a32aee71f6114e'
    end
  end

  describe '#series_title' do
    let(:document) do
      described_class.new(
        id: 'rushbenjaminandjulia_aspace_42ff52d27fd631ce27a32aee71f6114e',
        parent_unittitles_ssm: [
          'Benjamin and Julia Stockton Rush papers, bulk 1766-1845 and undated',
          'Letters, 1777-1824'
        ],
        parent_levels_ssm: %w[
          collection
          Series
        ]
      )
    end

    it 'uses the label from the first component that is a series' do
      expect(document.series_title).to eq 'Letters, 1777-1824'
    end
  end

  describe '#subseries_title' do
    let(:document) do
      described_class.new(
        id: 'uapresfew_aspace_ref334_5q6',
        parent_unittitles_ssm: [
          'William Preston Few records and papers, 1814-1971 and undated (bulk 1911-1940)',
          'Subject Files',
          'Trinity College'
        ],
        parent_levels_ssm: %w[
          collection
          Series
          Subseries
        ]
      )
    end

    it 'uses the label from the first component that is a subseries' do
      expect(document.subseries_title).to eq 'Trinity College'
    end
  end

  describe '#single_dao?' do
    let(:document) do
      described_class.new(
        digital_objects_ssm: [
          { href: 'https://example.com', label: 'Label 1', role: 'image-service' }.to_json
        ]
      )
    end

    it 'is single' do
      expect(document.single_dao?).to be true
      expect(document.multiple_daos?).to be false
    end
  end

  describe '#multiple_daos?' do
    let(:document) do
      described_class.new(
        digital_objects_ssm: [
          { href: 'https://example.com', label: 'Label 1', role: 'web-resource-link' }.to_json,
          { href: 'https://another-example.com', label: 'Label 2', role: 'web-resource-link' }.to_json
        ]
      )
    end

    it 'is not single' do
      expect(document.single_dao?).to be false
      expect(document.multiple_daos?).to be true
    end
  end

  describe '#dao_roles' do
    let(:document) do
      described_class.new(
        digital_objects_ssm: [
          { href: 'https://idn.duke.edu/ark:/87924/abc123', label: 'Label 1', role: 'image-service' }.to_json,
          { href: 'https://idn.duke.edu/ark:/87924/def456', label: 'Label 2', role: 'image-service' }.to_json,
          { href: 'https://example.com', label: 'Label 3', role: 'web-resource-link' }.to_json
        ]
      )
    end

    it 'is an array of unique role values' do
      expect(document.dao_roles).to eq(%w[image-service web-resource-link])
    end
  end

  describe '#dao_single_role' do
    context 'with a single dao' do
      let(:document) do
        described_class.new(
          digital_objects_ssm: [
            { href: 'https://idn.duke.edu/ark:/87924/abc123', label: 'Label 1', role: 'image-service' }.to_json
          ]
        )
      end

      it 'returns the role' do
        expect(document.dao_single_role).to eq('image-service')
      end
    end

    context 'with multiple daos' do
      let(:document) do
        described_class.new(
          digital_objects_ssm: [
            { href: 'https://idn.duke.edu/ark:/87924/abc123', label: 'Label 1', role: 'image-service' }.to_json,
            { href: 'https://idn.duke.edu/ark:/87924/def456', label: 'Label 2', role: 'image-service' }.to_json
          ]
        )
      end

      it 'returns nil' do
        expect(document.dao_single_role).to be nil
      end
    end
  end

  describe '#ddr_dao_count' do
    let(:document) do
      described_class.new(
        digital_objects_ssm: [
          { href: 'https://idn.duke.edu/ark:/87924/abc123', label: 'Label 1', role: 'image-service' }.to_json,
          { href: 'https://idn.duke.edu/ark:/87924/def456', label: 'Label 2', role: 'image-service' }.to_json,
          { href: 'https://idn.duke.edu/ark:/87924/ghi789', label: 'Label 3', role: 'audio-streaming' }.to_json
        ]
      )
    end

    it 'counts the DDR DAOs' do
      expect(document.ddr_dao_count).to eq(3)
      expect(document.multiple_ddr_daos?).to be true
    end
  end
end
