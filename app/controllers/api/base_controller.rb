module Api
  class BaseController < ApplicationController
    before_action :authenticate
    before_action :set_paper_trail_whodunnit  # uses `current_user`

    private

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        User.find_by(token: token)
      end
    end

    def current_user
      @current_user ||= authenticate
    end
  end
end
