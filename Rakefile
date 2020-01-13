# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

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
