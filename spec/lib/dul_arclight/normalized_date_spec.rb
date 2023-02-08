# frozen_string_literal: true

# Modeled after ArcLight core normalized_date_spec.rb but tests local customizations
# https://github.com/projectblacklight/arclight/blob/master/spec/lib/arclight/normalized_date_spec.rb

require 'rails_helper'

RSpec.describe DulArclight::NormalizedDate do
  subject(:normalized_date) { described_class.new(date_inclusive, date_bulk, date_other).to_s }

  let(:date_inclusive) { ['1990-2000'] }
  let(:date_bulk) { '1999-2005' }
  let(:date_other) { '2017' }

  context 'with three types of dates' do
    it 'shows all dates joined with commas -- bulk at end' do
      expect(normalized_date).to eq '1990-2000, 2017, (Majority of material found within 1999-2005)'
    end
  end

  context 'when the word bulk is in the bulk date' do
    let(:date_bulk) { 'bulk 1999' }

    it 'doesn\'t repeat bulk' do
      expect(normalized_date).to eq '1990-2000, 2017, (Majority of material found within 1999)'
    end
  end

  context 'when it has a bulk date without inclusive' do
    let(:date_inclusive) { nil }
    let(:date_bulk) { '1999' }
    let(:date_other) { nil }

    it 'still shows bulk' do
      expect(normalized_date).to eq '(Majority of material found within 1999)'
    end
  end
end
