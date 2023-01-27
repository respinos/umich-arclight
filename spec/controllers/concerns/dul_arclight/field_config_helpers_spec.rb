# frozen_string_literal: true

require 'rails_helper'

class TestController
  include DulArclight::FieldConfigHelpers
end

RSpec.describe DulArclight::FieldConfigHelpers do
  subject(:helper) { TestController.new }

  let(:RIGHTS_STATEMENTS) do # rubocop:disable RSpec/VariableName
    {
      'http://rightsstatements.org/vocab/InC/1.0/' => {
        'title' => 'In Copyright',
        'icon_1' => 'inc'
      },
      'https://creativecommons.org/licenses/by-nc-nd/4.0/' => {
        'title' => 'Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)',
        'icon_1' => 'cc',
        'icon_2' => 'by',
        'icon_3' => 'nc',
        'icon_4' => 'nd'
      }
    }
  end

  before do
    allow(helper).to receive(:view_context) { ActionView::Base.new }
  end

  describe '#keep_raw_values' do
    it 'returns the raw array of values' do
      content = helper.keep_raw_values(
        value: %w[one two three]
      )
      expect(content).to eq(%w[one two three])
    end
  end

  describe '#convert_rights_urls' do
    context 'when a paragraph contains *only* a URL' do
      context 'when the rights URL is present in config' do
        it 'renders the icons and text' do
          content = helper.convert_rights_urls(
            value: ['<p>https://creativecommons.org/licenses/by-nc-nd/4.0/</p>']
          )

          expect(content).to match(
            # rubocop:disable Layout/LineLength
            %r{^<p class="rights-statement"><a rel="license" itemprop="license" target="_blank" href="https://creativecommons.org/licenses/by-nc-nd/4.0/"><img class="rights-icon"}
            # rubocop:enable Layout/LineLength
          )
          expect(content.scan('rights-icon').size).to be 4
        end
      end

      context 'when the rights URL is not present in config' do
        it 'just renders the URL as a link' do
          content = helper.convert_rights_urls(
            value: ['<p>https://creativecommons.org/licenses/by-nc-nd/9.5/</p>']
          )
          expect(content).to eq(
            '<p><a class="external-link" href="https://creativecommons.org/licenses/by-nc-nd/9.5/">https://creativecommons.org/licenses/by-nc-nd/9.5/</a></p>'
          )
          expect(content.scan('rights-icon').size).to be 0
        end
      end
    end

    context 'when a paragraph contains a URL and other text' do
      it 'leaves the text intact and renders the URL as a link without icons' do
        content = helper.convert_rights_urls(
          value: ['<p>Please read https://creativecommons.org/licenses/by-nc-nd/4.0/ for more</p>']
        )
        expect(content).to eq(
          '<p>Please read <a class="external-link" href="https://creativecommons.org/licenses/by-nc-nd/4.0/">https://creativecommons.org/licenses/by-nc-nd/4.0/</a> for more</p>' # rubocop:disable Layout/LineLength
        )
        expect(content.scan('rights-icon').size).to be 0
      end
    end

    context 'when a paragraph has no URLs' do
      it 'leaves the text intact' do
        content = helper.convert_rights_urls(
          value: ['<p>Copyright for this collection is held by Duke University</p>']
        )
        expect(content).to eq(
          '<p>Copyright for this collection is held by Duke University</p>'
        )
      end
    end
  end

  describe '#singularize_extent' do
    it 'singularizes poorly worded extents like 1 boxes' do
      content = helper.singularize_extent(value: ['1 boxes', '11 boxes', '1 albums'])
      expect(content).to eq '1 box, 11 boxes, and 1 album'
    end
  end

  xdescribe '#ua_record_group_display' do
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
