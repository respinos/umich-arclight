# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'EAD downloads', type: :feature do
  context 'with collection URL followed by /xml' do
    it 'returns the EAD XML from the filesystem' do
      visit '/catalog/uaduketaekwondo/xml'
      xml = page.body
      expect(xml).to match(/<\?xml version="1.0"/)
      expect(xml).to match(/<ead xmlns="urn:isbn:1-931666-22-9"/)
    end
  end
end
