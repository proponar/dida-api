require 'rails_helper'

RSpec.describe 'Locations API', type: :request do
  before { create(:user, token: "sekkrit") }
  let(:credentials) { ActionController::HttpAuthentication::Token.encode_credentials('sekkrit') }

  describe 'GET /api/locations/search' do
    before do
      get '/api/locations/search', params: {id: 'pra'},  headers: { "Authorization" => credentials }
    end

    it 'returns search results' do
      expect(json).not_to be_empty
      expect(json_data.size).to eq(18)
    end
  end
end
