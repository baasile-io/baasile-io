$redis = Redis::Namespace.new(ENV['BAASILE_IO_HOSTNAME'], :redis => Redis.new)
