require 'rails_helper'

RSpec.describe 'Entries API', type: :request do
  let!(:sources) { create_list(:source, 100) }

  before { create(:user, token: "sekkrit") }
  let(:credentials) { ActionController::HttpAuthentication::Token.encode_credentials('sekkrit') }

  describe 'GET /api/sources' do
    before { get '/api/sources', headers: { "Authorization" => credentials } }

    it 'returns sources' do
      expect(json).not_to be_empty
      expect(json_data.size).to eq(100)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end
end
