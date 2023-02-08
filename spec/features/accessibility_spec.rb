# frozen_string_literal: true

# Duke Web Accessibility Guidelines specify a preference for
# WCAG 2.0 AA for most content and Section 508 for multimedia:
# https://web.accessibility.duke.edu/duke-guidelines

# Docs for using Axe Core RSpec:
# https://github.com/dequelabs/axe-core-gems/blob/develop/packages/axe-core-rspec/README.md

# See rule descriptions and tags:
# https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md

# For now, we'll use the default, which will check for WCAG 2.0 A/AA, 508, best practices
# and more. If in the future we need to target specific standards, we can use the
# tag clause (.according_to)

require 'rails_helper'
require 'axe-rspec'

RSpec.xdescribe 'Accessibility (WCAG, 508, Best Practices)', type: :feature, js: true, accessibility: true do
  describe 'homepage' do
    it 'is accessible' do
      visit '/'
      expect(page).to be_axe_clean
    end
  end

  # NOTE: axe-core struggles with modals + color contrast false positives
  # https://github.com/dequelabs/axe-core/issues/2329
  describe 'advanced search modal' do
    it 'is accessible' do
      visit '/'
      find('a.advanced_search').click
      expect(page).to be_axe_clean.skipping(:color_contrast)
    end
  end

  describe 'search results page (default)' do
    it 'is accessible' do
      visit '/?utf8=✓&group=true&search_field=all_fields&q=papers'
      expect(page).to be_axe_clean
    end
  end

  describe 'search results page (within collection / ungrouped)' do
    it 'is accessible' do
      visit '/?utf8=✓&search_field=all_fields&f%5Bcollection_sim%5D%5B%5D=Benjamin+and+Julia+Stockton+Rush+papers%2C+bulk+1766-1845+and+undated&q=letter'
      expect(page).to be_axe_clean
    end
  end

  describe 'collection page' do
    it 'is accessible' do
      visit '/catalog/rushbenjaminandjulia'
      expect(page).to be_axe_clean
    end
  end

  describe 'series page with over 100 child components' do
    it 'is accessible' do
      visit '/catalog/rushbenjaminandjulia_aspace_60bc65ac982c71ade8c13641188f6dbc'
      expect(page).to be_axe_clean
    end
  end

  describe 'deeply nested component (c04) page' do
    it 'is accessible' do
      visit '/catalog/strykerdeena_aspace_ref168_rey'
      expect(page).to be_axe_clean
    end
  end

  describe 'component with embedded DDR images' do
    it 'is accessible' do
      visit '/catalog/rushbenjaminandjulia_aspace_57d112f2de863cce982fa05420017497'
      expect(page).to be_axe_clean
    end
  end

  describe 'University Archives Record Groups page' do
    it 'is accessible' do
      visit '/collections/ua-record-groups'
      expect(page).to be_axe_clean
    end
  end
end
