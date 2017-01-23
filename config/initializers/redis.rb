$redis = Redis::Namespace.new("app", redis: Redis.new({url: ENV['REDIS_PROVIDER']}))
