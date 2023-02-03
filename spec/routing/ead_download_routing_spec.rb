# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ead_download routing', type: :routing do
  specify do
    expect(get: '/catalog/rushbenjaminandjulia/xml')
      .to route_to(controller: 'catalog', action: 'ead_download', id: 'rushbenjaminandjulia')
  end
end
