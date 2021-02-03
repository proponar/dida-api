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

  #describe 'GET /api/locations/lookup' do
  #end

  describe 'GET /api/locations/:id/parts' do
    context 'kod_obec query' do
      before { get '/api/locations/582786/parts?', headers: { "Authorization" => credentials } }
      # {"message":"Nalezeno 48 částí obce.","count":48,"data":[{"naz_cob":"Bohunice","kod_cob":"411671"},{"naz_cob":"Bosonohy","kod_cob":"411680"},{"naz_cob":"Brněnské Ivanovice","kod_cob":"012220"},{"naz_cob":"Brno-město","kod_cob":"411582"},{"naz_cob":"Bystrc","kod_cob":"411744"},{"naz_cob":"Černá Pole","kod_cob":"490423"},{"naz_cob":"Černovice","kod_cob":"411752"},{"naz_cob":"Chrlice","kod_cob":"054135"},{"naz_cob":"Dolní Heršpice","kod_cob":"012114"},{"naz_cob":"Dvorska","kod_cob":"033898"},{"naz_cob":"Holásky","kod_cob":"411698"},{"naz_cob":"Horní Heršpice","kod_cob":"411809"},{"naz_cob":"Husovice","kod_cob":"411701"},{"naz_cob":"Ivanovice","kod_cob":"055859"},{"naz_cob":"Jehnice","kod_cob":"058203"},{"naz_cob":"Jundrov","kod_cob":"490369"},{"naz_cob":"Kníničky","kod_cob":"011908"},{"naz_cob":"Kohoutovice","kod_cob":"411779"},{"naz_cob":"Komárov","kod_cob":"411795"},{"naz_cob":"Komín","kod_cob":"411957"},{"naz_cob":"Královo Pole","kod_cob":"411965"},{"naz_cob":"Lesná","kod_cob":"411710"},{"naz_cob":"Líšeň","kod_cob":"411825"},{"naz_cob":"Maloměřice","kod_cob":"490377"},{"naz_cob":"Medlánky","kod_cob":"411850"},{"naz_cob":"Mokrá Hora","kod_cob":"411884"},{"naz_cob":"Nový Lískovec","kod_cob":"411868"},{"naz_cob":"Obřany","kod_cob":"411841"},{"naz_cob":"Ořešín","kod_cob":"112682"},{"naz_cob":"Pisárky","kod_cob":"490385"},{"naz_cob":"Ponava","kod_cob":"411973"},{"naz_cob":"Přízřenice","kod_cob":"012149"},{"naz_cob":"Řečkovice","kod_cob":"411876"},{"naz_cob":"Sadová","kod_cob":"411981"},{"naz_cob":"Slatina","kod_cob":"411892"},{"naz_cob":"Soběšice","kod_cob":"411728"},{"naz_cob":"Staré Brno","kod_cob":"411591"},{"naz_cob":"Starý Lískovec","kod_cob":"411906"},{"naz_cob":"Stránice","kod_cob":"411621"},{"naz_cob":"Štýřice","kod_cob":"411604"},{"naz_cob":"Trnitá","kod_cob":"490393"},{"naz_cob":"Tuřany","kod_cob":"012173"},{"naz_cob":"Útěchov","kod_cob":"175552"},{"naz_cob":"Veveří","kod_cob":"411639"},{"naz_cob":"Žabovřesky","kod_cob":"411922"},{"naz_cob":"Zábrdovice","kod_cob":"490407"},{"naz_cob":"Žebětín","kod_cob":"195677"},{"naz_cob":"Židenice","kod_cob":"490415"}]}

      it 'returns parts' do
        expect(json).not_to be_empty
        expect(json_data.size).to eq(48)
        expect(json_data).to include({"naz_cob"=>"Jundrov", "kod_cob"=>"490369"})
      end
    end
  end
end
