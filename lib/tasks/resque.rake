require 'resque/tasks'
require 'resque/pool/tasks'

task 'resque:setup' => :environment

# https://github.com/nevans/resque-pool#rake-task-config
task 'resque:pool:setup' do
  # close any sockets or files in pool manager ...
  ActiveRecord::Base.connection.disconnect!

  # ... and re-open them in the resque worker parent
  Resque::Pool.after_prefork do |_job|
    ActiveRecord::Base.establish_connection
    Resque.redis.client.reconnect
  end
end
