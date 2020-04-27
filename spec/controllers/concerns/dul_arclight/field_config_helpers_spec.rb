# frozen_string_literal: true

require 'spec_helper'

class TestController
  include DulArclight::FieldConfigHelpers
end

RSpec.describe DulArclight::FieldConfigHelpers do
  subject(:helper) { TestController.new }

  describe '#singularize_extent' do
    it 'singularizes poorly worded extents like 1 boxes' do
      content = helper.singularize_extent(value: ['1 boxes', '11 boxes', '1 albums'])
      expect(content).to eq '1 box, 11 boxes, and 1 album'
    end
  end
end
