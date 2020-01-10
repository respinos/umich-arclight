# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'solr_wrapper/rake_task' unless Rails.env.production?

# Borrowed from ArcLight Demo app
# https://github.com/sul-dlss/arclight-demo/blob/master/Rakefile

# Load SOLR_URL from our configuration file
solr_config = YAML.load(ERB.new(File.read('./config/blacklight.yml')).result)
ENV['SOLR_URL'] = solr_config[Rails.env]['url']

# Read the repository configuration
repo_config = YAML.load(File.read('./config/repositories.yml'))

namespace :sample do
  desc 'Index sample EAD files into Solr'
  task seed: [:'arclight:destroy_index_docs'] do
    # Identify the configured repos
    repo_config.keys.map do |repository|
      # Index a directory with a given repository ID that matches its filename
      system("DIR=./sample-ead/#{repository} REPOSITORY_ID=#{repository} rake arclight:index_dir")
    end
  end
end