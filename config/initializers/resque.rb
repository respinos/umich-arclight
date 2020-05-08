require 'resque'

if ENV['REDIS_URL'].present?
  Resque.redis = ENV['REDIS_URL']
end
