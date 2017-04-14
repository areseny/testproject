HealthMonitor.configure do |config|
  config.cache
  config.redis
  config.sidekiq

  config.redis.configure do |redis_config|
    # may need to be specified for a custom redis location/port
    # redis_config.url = 'redis://user:pass@example.redis.com:90210/'
  end
end