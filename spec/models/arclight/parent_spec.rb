# frozen_string_literal: true

# Based on:
# https://github.com/projectblacklight/arclight/blob/master/spec/models/arclight/parent_spec.rb
# Last checked for updates: ArcLight v0.3.0.

require 'rails_helper'

RSpec.describe Arclight::Parent do
  subject(:instance) { described_class.new(id: 'abc', label: 'ABC', eadid: '123', level: 'collection') }

  describe '#global_id' do
    context 'when the eadid is the id' do
      subject(:instance) { described_class.new(id: 'abc', label: 'ABC', eadid: 'abc', level: 'collection') }

      it 'returns the id (and does not duplicate the id)' do
        expect(instance.global_id).to eq 'abc'
      end
    end

    it 'returns a correct global identifier with an underscore' do
      expect(instance.global_id).to eq '123_abc'
    end
  end
end
