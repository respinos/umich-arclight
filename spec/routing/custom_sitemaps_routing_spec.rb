# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'custom_sitemaps routing', type: :routing do
  xspecify do
    expect(get: '/custom_sitemaps/nlm_history_of_medicine.xml')
      .to route_to(controller: 'custom_sitemaps', action: 'index', id: 'nlm_history_of_medicine', format: 'xml')
    expect(get: '/custom_sitemaps/nlm_history_of_medicine')
      .to route_to(controller: 'custom_sitemaps', action: 'index', id: 'nlm_history_of_medicine', format: 'xml')
  end
end
