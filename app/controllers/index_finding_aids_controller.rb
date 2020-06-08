class IndexFindingAidsController < ApplicationController
  # Relative file path pattern for documents we want to index
  COMMITTED_FILE_PATTERN = Regexp.new('^ead/([^/]+)/')

  # https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#push-events
  GITLAB_PUSH_EVENT = 'Push Hook'.freeze

  skip_forgery_protection
  before_action :validate_token
  before_action :validate_push_event
  before_action :update_finding_aid_data

  # Endpoint for a GitLab Webhook push event
  def create
    enqueue_index_jobs
    enqueue_delete_jobs
    head :accepted
  end

  private

  def enqueue_index_jobs
    adds_mods.each do |path|
      next unless m = path.scan(COMMITTED_FILE_PATTERN).first

      repo_id = m.first
      full_path = File.join(DulArclight.finding_aid_data, path)
      IndexFindingAidJob.perform_later(full_path, repo_id)
    end
  end

  def enqueue_delete_jobs
    removed.each do |path|
      ead_id = File.basename(path, '.xml')
      DeleteFindingAidJob.perform_later(ead_id)
    end
  end

  def adds_mods
    added | modified
  end

  def commits
    params['commits']
  end

  def added
    commits.map { |c| c['added'] }.flatten
  end

  def modified
    commits.map { |c| c['modified'] }.reduce(:|)
  end

  def removed
    commits.map do |c|
      c['removed'].select { |path| COMMITTED_FILE_PATTERN.match?(path) }
    end.flatten
  end

  def validate_push_event
    return if request.headers['X-Gitlab-Event'] == GITLAB_PUSH_EVENT

    head :forbidden
  end

  def validate_token
    return if request.headers['X-Gitlab-Token'] == DulArclight.gitlab_token

    head :unauthorized
  end

  def update_finding_aid_data
    return if system('git pull', chdir: DulArclight.finding_aid_data)

    head :internal_server_error
  end
end
