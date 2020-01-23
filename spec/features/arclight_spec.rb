# frozen_string_literal: true

# Replicated from ArcLight core

require 'spec_helper'

RSpec.describe 'Arclight', type: :feature do
  it 'navigates to homepage' do
    visit '/'
    expect(page).to have_css 'h1', text: 'Archival Collections at Duke'
  end
end
