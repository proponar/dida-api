require 'rails_helper'

RSpec.describe 'Entries API', type: :request do
  # initialize test data 
  let!(:entries) { create_list(:entry, 10) }
  let(:entry_id) { entries.first.id }

  # Test suite for GET /entries
  describe 'GET /entries' do
    # make HTTP get request before each example
    before { get '/entries' }

    it 'returns entries' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /entries/:id
  describe 'GET /entries/:id' do
    before { get "/entries/#{entry_id}" }

    context 'when the record exists' do
      it 'returns the entry' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(entry_id)
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
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  # Test suite for POST /entries
  describe 'POST /entries' do
    # valid payload
    let(:valid_attributes) { { heslo: 'Learn Elm', created_by: '1' } }

    context 'when the request is valid' do
      before { post '/entries', params: valid_attributes }

      it 'creates a entry' do
        expect(json['heslo']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/entries', params: { heslo: 'Foobar' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Created by can't be blank/)
      end
    end
  end

  # Test suite for PUT /entries/:id
  describe 'PUT /entries/:id' do
    let(:valid_attributes) { { heslo: 'Shopping' } }

    context 'when the record exists' do
      before { put "/entries/#{entry_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /entries/:id
  describe 'DELETE /entries/:id' do
    before { delete "/entries/#{entry_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
