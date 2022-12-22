# frozen_string_literal: true

require_relative '../../config/application'
require 'dul_arclight'
require 'benchmark'

# Read the repository configuration
repo_config = YAML.safe_load(File.read('./config/repositories.yml'))

namespace :dul_arclight do
  desc 'Reindex all finding aids in the data directory via background jobs'
  task reindex_everything: :environment do
    puts "Looking in #{DulArclight.finding_aid_data} ..."

    # Find our configured repositories, get their IDs
    repo_config.keys.each do |repo_id|
      puts repo_id

      Dir.glob(File.join(DulArclight.finding_aid_data, 'ead', repo_id, '*.xml')) do |path|
        puts path
        IndexFindingAidJob.perform_later(path, repo_id)
      end
    end

    puts 'All collections queued for re-indexing.'
  end

  desc 'Reindex all finding aids for one repo via background jobs; use REPOSITORY_ID=<myid>'
  task reindex_repository: :environment do
    raise 'Please specify your repository, ex. REPOSITORY_ID=<myid>' unless ENV['REPOSITORY_ID']

    repo_id = ENV['REPOSITORY_ID']
    puts "Reindexing #{repo_id}"

    Dir.glob(File.join(DulArclight.finding_aid_data, 'ead', repo_id, '*.xml')) do |path|
      puts path
      IndexFindingAidJob.perform_later(path, repo_id)
    end
  end
end
