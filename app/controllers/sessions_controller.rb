class SessionsController < ApplicationController
  def create
    redirect_to launchbar_url
  end

  private

  def launchbar_url
    "x-launchbar:action/com.github.LaunchBar.action.GitHub/setToken?token=#{token}"
  end

  def token
    request.env['omniauth.auth']['credentials']['token']
  end
end
