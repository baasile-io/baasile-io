$redis = Redis::Namespace.new("app", redis: Redis.new(url: ENV.fetch('REDIS_PROVIDER', 'REDIS_URL')))
