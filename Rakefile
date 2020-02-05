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
    repo_config.keys.map do |repository|
      # Index a directory with a given repository ID that matches its filename
      system("DIR=./sample-ead/#{repository} REPOSITORY_ID=#{repository} rake arclight:index_dir")
    end
  end
end
