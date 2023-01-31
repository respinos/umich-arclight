# Overrides for select ArcLight Core rake tasks
# https://github.com/projectblacklight/arclight/blob/master/lib/tasks/index.rake

require 'benchmark'

# Override default arclight:index task to use ead2_config.rb indexing rules.
Rake::Task['arclight:index'].clear

namespace :arclight do
  desc 'Index an EAD document, use FILE=<path/to/ead.xml> and REPOSITORY_ID=<myid>'
  task index: :environment do
    raise 'Please specify your EAD document, ex. FILE=<path/to/ead.xml>' unless ENV['FILE']
    raise 'Please specify your Repository ID, ex. REPOSITORY_ID=<repo>' unless ENV['REPOSITORY_ID']

    print "UofM Arclight loading #{ENV['FILE']} to be indexed under #{ENV['REPOSITORY_ID']}...\n"
    elapsed_time = Benchmark.realtime do
      IndexFindingAidJob.perform_now(ENV['FILE'], ENV['REPOSITORY_ID'])
    end
    print "UofM Arclight indexed #{ENV['FILE']} (in #{elapsed_time.round(3)} secs).\n"
  end
end
