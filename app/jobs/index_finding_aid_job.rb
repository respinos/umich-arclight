require 'dul_arclight/errors'

class IndexFindingAidJob < ApplicationJob
  queue_as :index

  def perform(path, repo_id)
    env = { 'REPOSITORY_ID' => repo_id }

    # Calling the traject command directly here instead of
    # the arclight:index rake task because the latter
    # doesn't return the exit code for the traject command.
    cmd = %W[ bundle exec traject
              -u #{ENV['SOLR_URL']}
              -i xml
              -c ./lib/dul_arclight/traject/ead2_config.rb
              #{path} ]

    output = IO.popen(env, cmd, chdir: Rails.root, err: %i[child out], &:read)

    if $?.success?
      puts output
    else
      raise DulArclight::IndexError, output
    end
  end
end
