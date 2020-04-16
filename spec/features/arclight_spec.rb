# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Arclight', type: :feature do
  it 'navigates to homepage' do
    visit '/'
    expect(page).to have_css 'h1', text: 'Find Archival Materials'
    expect(page).to have_css 'h3', text: 'About This Site'
    expect(page).to have_css 'h3', text: 'Find More in the Catalog'
    expect(page).to have_css 'h3', text: 'Ask a Librarian'
  end

  it 'navigates to advanced search' do
    visit '/advanced'
    expect(page).to have_css 'h1', text: 'Advanced Search'
    expect(page).to have_css 'input', id: 'q'
  end

end