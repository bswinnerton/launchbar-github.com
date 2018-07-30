Rails.application.config.middleware.use OmniAuth::Builder do
  GITHUB_OAUTH_SCOPES = ['user', 'repo', 'gist', `read:discussion`].join(',').freeze
  OAUTH_KEY           = ENV.fetch('GITHUB_CLIENT_ID').freeze
  OAUTH_SECRET        = ENV.fetch('GITHUB_CLIENT_SECRET').freeze

  provider(:github, OAUTH_KEY, OAUTH_SECRET, scope: GITHUB_OAUTH_SCOPES)
end
