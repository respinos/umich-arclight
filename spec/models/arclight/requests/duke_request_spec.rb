# frozen_string_literal: true

# Modeled on other request mechanisms in ArcLight core:
# https://github.com/projectblacklight/arclight/blob/master/spec/models/arclight/requests/google_form_spec.rb
# https://github.com/projectblacklight/arclight/blob/master/spec/models/arclight/requests/aeon_web_ead_spec.rb

require 'rails_spec_helper'

RSpec.xdescribe 'Arclight::Requests::DukeRequest' do
  subject(:valid_object) { described_class.new(document) }

  context 'with one Aleph ID present' do
    let(:config) do
      instance_double 'Arclight::Repository',
                      request_url_for_type: 'https://requests.library.duke.edu/item/',
                      request_mappings_for_type: 'none'
    end

    let(:document) do
      instance_double 'Blacklight::SolrDocument',
                      bibnums: ['123'],
                      repository_config: config
    end

    describe '#base_request_url' do
      it 'returns from the repository config' do
        expect(valid_object.base_request_url).to eq 'https://requests.library.duke.edu/item/'
      end
    end

    describe '#url' do
      it 'returns the full request url' do
        expect(valid_object.url).to eq 'https://requests.library.duke.edu/item/123'
      end
    end
  end

  context 'with multiple Aleph IDs present' do
    let(:document) do
      instance_double 'Blacklight::SolrDocument',
                      bibnums: %w[123 456],
                      eadid: 'rushbenjaminandjulia'
    end

    describe '#catalog_serp_url' do
      it 'returns a link to a catalog search result searching the eadid' do
        expect(valid_object.catalog_serp_url).to \
          eq 'https://find.library.duke.edu/?search_field=isbn_issn&q=rushbenjaminandjulia'
      end
    end
  end
end
