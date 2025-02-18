require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DulArclight
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoload_paths += %W[#{config.root}/lib]
    # # Settings in config/environments/* take precedence over those specified here.
    # # Application configuration can go into files in config/initializers
    # # -- all .rb files in that directory are automatically loaded after loading
    # # the framework and any gems in your application.
    # config.action_mailer.default_options = {
    #   from: 'dul-arclight@%s' % ENV.fetch('APPLICATION_HOSTNAME', 'localhost'),
    #   reply_to: 'no-reply@duke.edu'
    # }
    # config.action_mailer.default_url_options = {
    #   host: ENV.fetch('APPLICATION_HOSTNAME', 'localhost')
    # }
  end
end
