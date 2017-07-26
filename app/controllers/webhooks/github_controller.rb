require 'net/http'

module Webhooks
  class GithubController < ApplicationController
    class HerokuRequestFailed < StandardError; end

    DIGEST = OpenSSL::Digest.new('sha1')
    SECRET = ENV.fetch('GITHUB_WEBHOOK_SECRET')

    skip_before_action :verify_authenticity_token

    def create
      return not_found unless is_authenticated?
      return unprocessable_entity unless tag_name.present?
      return unprocessable_entity if is_prerelease?

      if bump_download_url(tag_name)
        head 200, content_type: 'application/json'
      else
        head 503, content_type: 'application/json'
      end
    end

    private

    def not_found
      head 404, content_type: 'application/json'
    end

    def unprocessable_entity
      head 422, content_type: 'application/json'
    end

    def is_authenticated?
      request.headers.fetch('X-Hub-Signature') == signature
    end

    def signature
      signature = OpenSSL::HMAC.hexdigest(DIGEST, SECRET, request_payload)
      "sha1=#{signature}"
    end

    def request_payload
      request.body.rewind
      request.body.read
    end

    def is_prerelease?
      params.dig('release', 'prerelease')
    end

    def tag_name
      params.dig('release', 'tag_name')
    end

    def bump_download_url(tag_name)
      uri = URI.parse('https://api.heroku.com/apps/launchbar-github/config-vars')

      request_headers = {
        'Accept': 'application/vnd.heroku+json; version=3',
        'Authorization': "Bearer #{ENV.fetch('HEROKU_TOKEN')}",
        'Content-Type': 'application/json',
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      heroku_request = Net::HTTP::Patch.new(uri.request_uri, request_headers)
      heroku_request.body = { "DOWNLOAD_URL" => download_url }.to_json
      heroku_response = http.request(heroku_request)

      heroku_response.code == '200' ? true : false
    end

    def download_url
      "https://github.com/bswinnerton/launchbar-github/releases/download/#{tag_name}/github.lbaction.zip"
    end
  end
end
