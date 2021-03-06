require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# Bundler.require(:default, Rails.env)

module FoodFindersApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # config.middleware.use ActionDispatch::Request

    config.logger = ActiveSupport::TaggedLogging.new(
      Logger.new(File.join(Rails.root, 'log', 'test.log'))
    )

    config.active_job.queue_adapter = :sidekiq

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        # origins 'localhost:3000'
        origins(
          'localhost:3000',
          'localhost:8080',
          'http://foodbuddies.heregorun.com:2000',
          'http://foodbuddies.heregorun.com:8080',
          'http://foodbuddies.heregorun.com:443',
          'https://foodbuddies.heregorun.com:2000',
          'https://foodbuddies.heregorun.com:8080',
          'https://foodbuddies.heregorun.com:443'
        )

        resource(
          '*',
          headers: :any,
          methods: %i[get post put patch delete options head],
          credentials: true
        )
      end
    end
  end
end
