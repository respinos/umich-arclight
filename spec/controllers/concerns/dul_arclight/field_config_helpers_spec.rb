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

  describe '#ua_record_group_display' do
    context 'when a top-level record group has a title in the yml config' do
      it 'concatenates number & title' do
        content = helper.ua_record_group_display('31')
        expect(content).to eq '31 &mdash; Student/Campus Life'
      end
    end

    context 'when a top-level group is unlisted or untitled in the yml config' do
      it 'concatenates number & "Unknown" for title' do
        content = helper.ua_record_group_display('9999')
        expect(content).to eq '9999 &mdash; Unknown'
      end
    end

    context 'when a subgroup has a title in the yml config' do
      it 'concatenates number & title' do
        content = helper.ua_record_group_display('31:11')
        expect(content).to eq '11 &mdash; Student Organizations - Recreational Sports'
      end
    end

    context 'when a subgroup is unlisted or untitled in the yml config' do
      it 'concatenates number & "Unknown" for title' do
        content = helper.ua_record_group_display('31:9999')
        expect(content).to eq '9999 &mdash; Unknown'
      end
    end
  end
end
