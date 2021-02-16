# frozen_string_literal: true

# Compare to testing framework from ArcLight Core; see:
# https://github.com/projectblacklight/arclight/blob/master/spec/spec_helper.rb

ENV['RAILS_ENV'] ||= 'test'

# Use our actual repositories config file, not a test one.
ENV['REPOSITORY_FILE'] ||= 'config/repositories.yml'
require File.expand_path('../config/environment', __dir__)
SPEC_ROOT = Pathname.new(__dir__)

require 'rspec/rails'
require 'selenium-webdriver'

Capybara.javascript_driver = :selenium_remote

Capybara.register_driver :selenium_remote do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  # See Chromium/Chromedriver capabilities:
  # https://chromedriver.chromium.org/capabilities
  # https://peter.sh/experiments/chromium-command-line-switches/
    chromeOptions: { args: [
      'headless',
      'no-sandbox',
      'disable-gpu',
      'disable-infobars',
      'window-size=1400,1000',
      'enable-features=NetworkService,NetworkServiceInProcess'
    ] }
  )

  Capybara::Selenium::Driver.new(app,
                                 browser: :remote,
                                 desired_capabilities: capabilities,
                                 url: 'http://selenium:4444/wd/hub')
end

# Puma defaults to Threads: '0:4' (min_threads:max_threads);
# Tests with AJAX requests seem to timeout & fail unless setting to 1:1
Capybara.server = :puma, { Threads: '1:1' }

Capybara.server_port = '3002'
Capybara.server_host = '0.0.0.0'
Capybara.app_host = "http://app:#{Capybara.server_port}"

Capybara.always_include_port = true
Capybara.default_max_wait_time = 30 # our ajax responses are sometimes slow

Capybara.enable_aria_label = true

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
