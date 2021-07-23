class Api::AuthController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  # FIXME: move to config
  CLIENT_ID = '463940228204-8h8413o241etnc0q0ifvjq57st8vde49.apps.googleusercontent.com'

  def auth
    # read basic auth headers
    authenticate_or_request_with_http_basic('Administration') do |username, password|

      # for oauth, username is the JWT token
      if params['requester_type'] == 'oauth'
        token = username
        begin
          TokenValidator.new(token, CLIENT_ID).validate
          user = User.find_or_create_user_by_jwt_token(token)
        rescue
          user = nil
        end
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
