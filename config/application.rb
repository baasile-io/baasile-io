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

    # Security
    config.middleware.use ::ApiAuthMiddleware
    config.middleware.use Rack::Attack
    config.middleware.use I18n::JS::Middleware

    # add custom validators path
    config.autoload_paths += %W["#{config.root}/app/validators/"]
  end
end
