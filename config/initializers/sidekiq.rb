Sidekiq.configure_server do |config|
  config.redis = { url: "#{ENV.fetch('REDIS_PROVIDER', 'REDIS_URL')}/0/sidekiq" }
end
