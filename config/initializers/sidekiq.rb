Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_PROVIDER'] }
end
