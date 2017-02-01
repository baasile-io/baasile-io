$redis = Redis::Namespace.new("app", redis: Redis.new(url: ENV['REDISCLOUD_URL']))
