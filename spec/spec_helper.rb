# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

# Use our actual repositories config file, not a test one.
ENV['REPOSITORY_FILE'] ||= 'config/repositories.yml'
require File.expand_path('../config/environment', __dir__)
SPEC_ROOT = Pathname.new(__dir__)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
