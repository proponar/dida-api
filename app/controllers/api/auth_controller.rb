class Api::AuthController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  def auth
    # read basic auth headers
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      user = User.find_by(:name => username, :password => password)
      # TODO: generate temporaty tokens per session
      render json: { auth_token: user.token }
    end
  end
end
