class Api::AuthController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  def auth
    # read basic auth headers
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      if params['requester_type'] == 'oauth'
        # TODO: verify the token
        user = User.find_or_create_user_by_jwt_token(username)
      else
        user = User.find_by(:name => username, :password => password)
      end

      if user.blank?
        render json: { message: 'Špatný login, nebo heslo.' }, status: :unauthorized
        return
      end

      # TODO: generate temporary tokens per session
      render json: { auth_token: user.token, name: user.name }
    end
  end
end
