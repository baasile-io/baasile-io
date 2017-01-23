Sidekiq.configure_server do |config|
  config.redis = { url: "#{ENV['REDISCLOUD_URL']}/0/sidekiq" }
end
