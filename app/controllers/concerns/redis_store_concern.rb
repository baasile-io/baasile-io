module RedisStoreConcern
  extend ActiveSupport::Concern

  # Gets value of a single Redis hash key
  def cache_hget(hash, field)
    redis.hget(hash, field)
  end

  # Get value of multiple keys in a Redis hash
  def cache_hmget(hash, *fields)
    redis.hmget(hash, *fields)
  end

  # Get all fields and values from Redis at once by passing in the hash name
  def cache_hgetall(hash)
    redis.hgetall(hash)
  end

  # Saves the current token as a hash with user info
  def cache_hmset(hash, *field_value)
    redis.mapped_hmset(hash, *field_value)
  end

  # Expire an item
  def cache_expire(hash, time)
    redis.expire(hash, time)
  end

  private

  def redis
    $redis
  end
end
