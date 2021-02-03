require 'rails_helper'

RSpec.describe Source, type: :model do
  describe 'self.to_csv' do
    subject { Source.to_csv }
    let!(:source) { FactoryBot.create(:source) }
    it 'returns string data' do
      expect(subject).to be_kind_of(String)
      expect(subject.split("\n").length).to eq(2)
    end
  end

  describe 'self.csv_import' do
    it 'loads the correct number of items' do
      test_csv = <<EOD
#cislo,autor,name,nazev2,rok,bibliografie,typ,lokalizace_text,lokalizace,rok_sberu
1,"ADÁMEK, K. V.",Lid na Hlinecku.,,1900,"Praha: Archaeologická kommisse při České akademii císaře Františka Josefa pro vědy, slovesnost a umění, 1900.",Kniha,,,1900
2,"AMBROŽ, J.",Telč JI.,,1966,1966.,Excerpta,Telč JI,Telč JI,1966
3,"AMBROŽ, J.",Telč JI.,,1967,1967.,Excerpta,Telč JI,Telč JI,1967
4,"AMBROŽ, J.",Telč JI.,,1968,1968.,Excerpta,Telč JI,Telč JI,1968
EOD
      counter = Source.csv_import(test_csv)
      expect(counter).to be(4)
      expect(Source.find_by(cislo: 2).name).to eq('Telč JI.')
    end
  end
end
