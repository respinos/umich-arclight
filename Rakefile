# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

# Read the repository configuration
repo_config = YAML.safe_load(File.read('./config/repositories.yml'))

namespace :seed do
  # Seed Test EAD Data (From spec/fixtures/*)
  # Based on https://github.com/projectblacklight/arclight/blob/master/tasks/arclight.rake
  # ==============================
  desc 'Index EAD file fixtures into Solr for testing'
  task fixtures: [:'arclight:destroy_index_docs'] do
    puts 'Seeding index with data from spec/fixtures/ead...'
    Dir.glob('spec/fixtures/ead/*.xml').each do |file|
      system("FILE=#{file} rake arclight:index") # no REPOSITORY_ID
    end
    Dir.glob('spec/fixtures/ead/*').each do |dir|
      next unless File.directory?(dir)

      system("REPOSITORY_ID=#{File.basename(dir)} " \
             'REPOSITORY_FILE=./config/repositories.yml ' \
             "DIR=#{dir} " \
             'rake arclight:index_dir')
    end
  end

  # Seed Sample EAD Data (From sample-ead/*)
  # Based on https://github.com/sul-dlss/arclight-demo/blob/master/Rakefile
  # ==============================
  desc 'Index sample EAD files into Solr'
  task samples: [:'arclight:destroy_index_docs'] do
    puts 'Seeding index with data from sample-ead directory...'
    # Identify the configured repos
    repo_config.keys.each do |repository|
      # Index a directory with a given repository ID that matches its filename
      system("DIR=./sample-ead/#{repository} REPOSITORY_ID=#{repository} rake arclight:index_dir")
    end
  end
end

namespace :dul_arclight do
  # =========================================================================
  # FULL REINDEXING TASKS: process all of the finding aids
  # =========================================================================

  desc 'Full reindex of all EAD data (In /data/ead/*)'
  # NOTE: this will remove any deleted components from
  # the index but will NOT remove any deleted collections
  # (EAD files).
  # =====================================================
  task :reindex_all do
    puts 'Indexing all data from /data/ead directory...'
    # Identify the configured repos
    repo_config.keys.each do |repository|
      # Index a directory with a given repository ID that matches its filename
      system("DIR=#{ENV['FINDING_AID_DATA']}/#{repository} REPOSITORY_ID=#{repository} rake arclight:index_dir")
    end
  end

  desc 'Full destroy and reindex of all EAD data (In /data/*)'
  # NOTE: this erases all index data before reindexing.
  task reindex_full_rebuild: %i[arclight:destroy_index_docs dul_arclight:reindex_all] do
    puts 'Index has been destroyed and rebuilt from /data directory.'
  end

  # =========================================================================
  # DELETE from the index using the EADID slug (repository irrelevant)
  # =========================================================================
  desc 'Delete one finding aid and all its components from the index, use EADID=<eadid>'
  task delete: :environment do
    raise 'Please specify your EAD slug, ex. EADID=<eadid>' unless ENV['EADID']

    puts "Deleting all documents from index with ead_ssi = #{ENV['EADID']}"
    Blacklight.default_index.connection.delete_by_query("ead_ssi:#{ENV['EADID']}")
    Blacklight.default_index.connection.commit
    puts "Deleted #{ENV['EADID']}"
  end

  # =========================================================================
  # UNSEEN indexing tasks: could be used in cases where one needs to resume a
  # long-running indexing command that has gotten interrupted.
  # TODO: Remove these tasks if the resque background job processing sufficiently
  #       addresses these indexing needs.
  # =========================================================================
  desc 'Index a file but only if its slug is not already found in the index. Use FILE=<path/to/ead.xml> and REPOSITORY_ID=<myid>'
  # Modeled after:
  # https://github.com/projectblacklight/blacklight/blob/master/lib/railties/blacklight.rake#L43
  task :index_unseen, [:controller_name] => [:environment] do
    raise 'Please specify your EAD document, ex. FILE=<path/to/ead.xml>' unless ENV['FILE']

    print "Checking if #{ENV['FILE']} is already indexed...\n"

    doc_id = File.basename(ENV['FILE'], '.*')
    puts "Checking for #{doc_id} in Solr\n"
    response = Blacklight.default_index.connection.select(params: { q: "id:#{doc_id}" })
    num_found = response.fetch('response')&.fetch('numFound')

    if num_found.zero?
      system('rake arclight:index')
    else
      puts "Skipping #{doc_id} -- already indexed"
    end
  end

  desc 'Index a directory of EADs, skipping files already indexed. Use DIR=<path/to/directory> and REPOSITORY_ID=<myid>'
  task :index_dir_unseen do
    raise 'Please specify your directory, ex. DIR=<path/to/directory>' unless ENV['DIR']

    Dir.glob(File.join(ENV['DIR'], '*.xml')).each do |file|
      system("rake dul_arclight:index_unseen FILE=#{file}")
    end
  end

  task :reindex_all_unseen do
    puts "Indexing all data from #{ENV['FINDING_AID_DATA']} directory..."
    # Identify the configured repos
    repo_config.keys.each do |repository|
      # Index a directory with a given repository ID that matches its filename
      system("DIR=#{ENV['FINDING_AID_DATA']}/#{repository} REPOSITORY_ID=#{repository} rake dul_arclight:index_dir_unseen")
    end
  end
end
