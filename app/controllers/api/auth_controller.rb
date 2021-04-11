class Api::AuthController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  def auth
    # read basic auth headers
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      user = User.find_by(:name => username, :password => password)
      if user.blank?
        render json: { message: 'Špatný login, nebo heslo.' }, status: 401
        return
      end

      # TODO: generate temporary tokens per session
      render json: { auth_token: user.token, name: user.name }
    end
  end
end
