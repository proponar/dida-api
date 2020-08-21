class Api::AuthController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  def auth
    # read basic auth headers
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      # TODO: verify user
      username == 'admin' && password == 'password'

      render json: { auth_token: 'sekkrit' }
    end
  end
end
