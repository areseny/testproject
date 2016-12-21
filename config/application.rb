require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

require_relative '../app/middleware/catch_json_parse_errors'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ink
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # config.assets.enabled = false
    # added on top of the rails 5.0 upgrade utility

    # from https://robots.thoughtbot.com/catching-json-parse-errors-with-custom-middleware
    # config.middleware.insert_before ActionDispatch::ParamsParser, "CatchJsonParseErrors"

    config.ink_api = config_for(:ink_api)

    config.debug_exception_response_format = :default

    config.middleware.use ::CatchJsonParseErrors
    config.middleware.use Rack::Cors do
      allow do
        origins '*'#/\Alocalhost(:\d+)?\z/, /\A(.*)\.coko\.foundation(:\d+)?\z/
        resource '*',
                 :headers => :any,
                 :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
                 :methods => [:get, :post, :options, :delete, :put]
      end
    end
  end
end
