require 'rails_helper'

RSpec.describe 'LocationTexts API', type: :request do
  before { create(:user, token: "sekkrit") }
  let(:credentials) { ActionController::HttpAuthentication::Token.encode_credentials('sekkrit') }

  describe 'GET /api/location_texts' do
    before { get '/api/location_texts', headers: { "Authorization" => credentials } }

    it 'returns location texts' do
      expect(json).not_to be_empty
      expect(json_data.size).to be >= 50
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end
end
