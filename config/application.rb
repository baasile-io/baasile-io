require_relative 'boot'

require 'rails/all'

require_relative '../lib/api_auth_middleware'
require_relative '../lib/catch_json_parse_errors_middleware'
require_relative '../lib/load_appconfigs_middleware'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BaasileIo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Background jobs
    config.active_job.queue_adapter = :sidekiq

    # Public API headers
    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => 'POST, PUT, DELETE, GET, OPTIONS, PATCH, HEAD',
      'Access-Control-Request-Method' => 'POST, PUT, DELETE, GET, OPTIONS, PATCH, HEAD'
    }

    # Appconfigs
    config.middleware.use ::LoadAppconfigsMiddleware

    # Monitoring
    config.middleware.use Airbrake::Rack::Middleware

    # Security
    config.middleware.use ::CatchJsonParseErrorsMiddleware
    config.middleware.use ::ApiAuthMiddleware
    config.middleware.use Rack::Attack
    config.middleware.use I18n::JS::Middleware

    # add custom validators path
    config.autoload_paths += %W["#{config.root}/app/validators/"]

    # add custom inputs
    config.autoload_paths += %W["#{config.root}/app/inputs/"]

    # add services path
    config.autoload_paths += %W["#{config.root}/app/services/**/*"]
  end
end
