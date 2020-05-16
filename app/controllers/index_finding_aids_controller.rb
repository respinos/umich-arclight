class IndexFindingAidsController < ApplicationController
  # Relative file path pattern for documents we want to index
  COMMITTED_FILE_PATTERN = Regexp.new('^ead/([^/]+)/')

  # https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#push-events
  GITLAB_PUSH_EVENT = 'Push Hook'.freeze

  skip_forgery_protection
  before_action :validate_token
  before_action :validate_push_event
  before_action :update_finding_aid_data

  def create
    adds_mods.each do |path|
      next unless m = path.scan(COMMITTED_FILE_PATTERN).first

      repo_id = m.first
      full_path = File.join(DulArclight.finding_aid_data, path)
      IndexFindingAidJob.perform_later(full_path, repo_id)
    end

    head :accepted
  end

  private

  def adds_mods
    params['commits'].reduce([]) do |memo, commit|
      memo |= commit['added']
      memo |= commit['modified']
    end
  end

  def validate_push_event
    head :forbidden unless request.headers['X-Gitlab-Event'] == GITLAB_PUSH_EVENT
  end

  def validate_token
    head :unauthorized unless request.headers['X-Gitlab-Token'] == DulArclight.gitlab_token
  end

  def update_finding_aid_data
    head :internal_server_error unless system('git pull', chdir: DulArclight.finding_aid_data)
  end
end
