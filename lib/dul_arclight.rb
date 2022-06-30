require_relative './dul_arclight/repository'
module DulArclight
  # The value used to authenticate the webhook
  # (not a repo deploy token)
  mattr_accessor :gitlab_token do
    ENV['GITLAB_TOKEN']
  end

  mattr_accessor :finding_aid_data do
    ENV.fetch('FINDING_AID_DATA', '/data')
  end

  mattr_accessor :google_analytics_tracking_id do
    ENV['GOOGLE_ANALYTICS_TRACKING_ID']
  end

  mattr_accessor :google_analytics_debug do
    ENV['GOOGLE_ANALYTICS_DEBUG']
  end
end
