require 'resque/pool/tasks'

# this task will get called before resque:pool:setup
# and preload the rails environment in the pool manager
desc 'Resque Setup'
task 'resque:setup' => :environment do
  # generic worker setup, e.g. Hoptoad for failed jobs
end

desc 'Resque Pool Setup'
task 'resque:pool:setup' => :environment do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  # and re-open them in the resque worker parent
  Resque::Pool.after_prefork do |_job|
    ActiveRecord::Base.establish_connection
  end
end
