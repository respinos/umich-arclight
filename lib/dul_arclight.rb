module DulArclight
  # The value used to authenticate the webhook
  # (not a repo deploy token)
  mattr_accessor :gitlab_token do
    ENV['GITLAB_TOKEN']
  end

  mattr_accessor :finding_aid_data do
    ENV.fetch('FINDING_AID_DATA', '/data')
  end
end
