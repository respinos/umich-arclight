require 'resque'

Resque.redis = ENV['REDIS_URL'] if ENV['REDIS_URL'].present?
