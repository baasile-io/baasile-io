require_relative 'boot'

require 'rails/all'

require_relative '../lib/api_auth_middleware'

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

    # Security
    config.middleware.use Airbrake::Rack::Middleware
    config.middleware.use ::ApiAuthMiddleware
    config.middleware.use Rack::Attack
    config.middleware.use I18n::JS::Middleware

    # add custom validators path
    config.autoload_paths += %W["#{config.root}/app/validators/"]
  end
end
