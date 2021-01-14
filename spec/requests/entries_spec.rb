require 'rails_helper'

RSpec.describe 'Entries API', type: :request do
  let!(:entries) { create_list(:entry, 10) }
  let(:entry_id) { entries.first.id }

  before { create(:user, token: "sekkrit") }
  let(:credentials) { ActionController::HttpAuthentication::Token.encode_credentials('sekkrit') }

  describe 'GET /api/entries' do
    before { get '/api/entries', headers: { "Authorization" => credentials } }
    # 2.6.1 :002 > ActionController::HttpAuthentication::Token.encode_credentials('sekkrit')
    #  => "Token token=\"sekkrit\""

    it 'returns entries' do
      expect(json).not_to be_empty
      expect(json_data.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /api/entries/:id' do
    before { get "/api/entries/#{entry_id}", headers: { "Authorization" => credentials } }

    context 'when the record exists' do
      it 'returns the entry' do
        expect(json).not_to be_empty
        expect(json['entry']).not_to be_empty
        expect(json['entry']['id']).to eq(entry_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:entry_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Heslo nebylo nalezeno/)
      end
    end
  end

  describe 'POST /api/entries' do
    let(:valid_attributes) { { entry: { heslo: 'abraka', kvalifikator: 'dabra', vyznam: 'blah', created_by: '1' } } }

    context 'when the request is valid' do
      before { post '/api/entries', params: valid_attributes, headers: { "Authorization" => credentials } }

      it 'creates a entry' do
        expect(json_data['heslo']).to eq('abraka')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/api/entries', params: { entry: { vyznam: 'Foobar' } }, headers: { "Authorization" => credentials } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      #it 'returns a validation failure message' do
      #  expect(response.body)
      #    .to match(/Validation failed: Created by can't be blank/)
      #end
    end
  end

  describe 'PUT /api/entries/:id' do
    let(:valid_attributes) { { entry: { heslo: 'Shopping' } } }

    context 'when the record exists' do
      before { put "/api/entries/#{entry_id}", params: valid_attributes, headers: { "Authorization" => credentials } }

      it 'updates the record' do
        #expect(response.body).to be_empty
        expect(response.body).to match(/Heslo bylo aktualizováno/)
        expect(response).to have_http_status(200)
      end

      #it 'returns status code 204' do
      #  expect(response).to have_http_status(204)
      #end
    end
  end

  describe 'DELETE /entries/:id' do
    before { delete "/api/entries/#{entry_id}", headers: { "Authorization" => credentials } }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
