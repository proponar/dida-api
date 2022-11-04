require 'rails_helper'

include ActionDispatch::TestProcess
include Rack::Test::Methods

RSpec.describe 'Exemps API', type: :request do
  let(:entry) { FactoryBot.create(:entry) }
  let(:entry_id) { entry.id }
  let(:full_entry) { entry_with_exemp }

  let(:exemp_data) {{
    "entryId": entry_id,
    # "id":448,
    "tvar_map": {},
    # "meanings": [
    #   {"id":46,"cislo":1,"vyznam":"zvíře","kvalifikator":nil},
    #   {"id":48,"cislo":3,"vyznam":"čert","kvalifikator":nil},
    #   {"id":47,"cislo":2,"vyznam":"nadávka","kvalifikator":"expr."}
    # ],
    "kvalifikator":"",
    "vyznam":"zvíře",
    # "meaning_id":46,
    "rod":nil,"rok":"1953",
    "exemplifikace":"kanec se jinam nesmí střílet, jen do voka",
    "vetne":true,"aktivni":true,"zdroj_id":1787,
    "zdroj_name":"Kladno 1–15.",
    "lokalizace_obec_id":"532576","lokalizace_obec_text":"Libušín KL",
    "lokalizace_cast_obce_id":nil,"lokalizace_cast_obce_text":nil,
    "lokalizace_text":"","lokalizace_format":"Libušín KL",
    "urceni":nil,"time":"22.01.2021 10:58:13","attachments":[]
  }}

  before { create(:user, token: "sekkrit") }
  let(:credentials) { ActionController::HttpAuthentication::Token.encode_credentials('sekkrit') }

  describe "POST entries/:entry_id/exemps" do
    before do
      post "/api/entries/#{entry_id}/exemps",
        params: exemp_data, headers: { "authorization" => credentials }
    end

    it 'returns status code 201' do
      expect(response).to have_http_status(201)
    end

    it 'creates a entry' do
      expect(json_data['exemplifikace']).to eq(exemp_data[:exemplifikace])
      expect(json_data['lokalizace_obec']).to eq('532576')
    end
  end

  describe "PUT entries/:entry_id/exemps/:id" do
    it 'updates given exemp' do
      put "/api/entries/#{entry_with_exemp.id}/exemps/#{entry_with_exemp.exemps[0].id}",
        headers: { "Authorization" => credentials },
        params: exemp_data.update({
          exemplifikace: 'foobar',
          lokalizace_obec: '532576',
        })

      expect(json_data['exemplifikace']).to eq('foobar')
      expect(json_data['lokalizace_obec']).to eq('532576')
    end
  end

  describe "GET entries/:entry_id/exemps" do
    it 'returns the exemp' do
      get "/api/entries/#{entry_with_exemp.id}/exemps",
        headers: { "Authorization" => credentials }
      expect(response).to have_http_status(200)
      expect(json['message']).to match("Nahrány všechny exemplifikace.")
    end
  end

  describe "DELETE entries/:entry_id/exemps/:id" do
    it 'deletes the exemp' do
      delete "/api/entries/#{entry_with_exemp.id}/exemps/#{entry_with_exemp.exemps[0].id}",
        headers: { "Authorization" => credentials }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to match({ 'message' => "Exemplifikace smazána" })
    end
  end

  describe "POST entries/:entry_id/exemps/:id/attach" do
    it 'stores attachments' do
      post "/api/entries/#{entry_with_exemp.id}/exemps/#{entry_with_exemp.exemps[0].id}/attach",
        headers: { "Authorization" => credentials, 'X-File-Name' => 'foobar.txt' },
        params: { foo: 'bar' }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to match({ 'message' => "Příloha byla připojena" })
    end
  end

  # detach entries/${entryId}/exemps/${exempId}/detach`
  describe "POST entries/:entry_id/exemps/:id/detach" do
    # FIXME
  end

  describe "POST entries/:entry_id/exemps/:id/coordinates" do
    it 'returns coordinates' do
      get "/api/entries/#{entry_with_exemp.id}/exemps/#{entry_with_exemp.exemps[0].id}/coordinates",
        headers: { "authorization" => credentials }
      coordinates = JSON.parse(response.body)['coordinates']
      expect(coordinates).to have_key('lng')
      expect(coordinates).to have_key('lat')
    end
  end

  describe "POST search" do
    it 'return exemps' do # TODO: sorted by heslo, urceni, lokalizace, zdroj
      post "/api/search",
        headers: { "authorization" => credentials }
      expect(response).to have_http_status(200)
      expect(json).to have_key('total')
      expect(json).to have_key('message')
      expect(json).to have_key('data')
    end
  end
end
