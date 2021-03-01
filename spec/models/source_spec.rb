require 'rails_helper'

RSpec.describe Source, type: :model do
  describe 'self.to_csv' do
    subject { Source.to_csv }
    let!(:source) { FactoryBot.create(:source) }
    it 'returns string data' do
      expect(subject).to be_kind_of(String)
      expect(subject.split("\n").length).to be > 1
    end
  end

  describe 'self.csv_import' do
    it 'loads the correct number of items' do
      test_csv = <<EOD
#cislo,autor,name,nazev2,rok,bibliografie,typ,lokalizace_text,lokalizace,rok_sberu
1000001,"ADÁMEK, K. V.",Lid na Hlinecku.,,1900,"Praha: Archaeologická kommisse při České akademii císaře Františka Josefa pro vědy, slovesnost a umění, 1900.",Kniha,,,1900
1000002,"AMBROŽ, J.",Telč JI.,,1966,1966.,Excerpta,Telč JI,Telč JI,1966
1000003,"AMBROŽ, J.",Telč JI.,,1967,1967.,Excerpta,Telč JI,Telč JI,1967
1000004,"AMBROŽ, J.",Telč JI.,,1968,1968.,Excerpta,Telč JI,Telč JI,1968
EOD
      counter = Source.csv_import(test_csv)
      expect(counter).to be(4)
      expect(Source.find_by(cislo: 1000002).name).to eq('Telč JI.')
    end
  end

  describe 'self.guess_source' do
    examples = {
      'Bachmannová, Za života se stane ledacos' => {
        'name'  => "Za života se stane ledacos. Vyprávěnky ze Železnobrodska.",
        'autor' => "BACHMANNOVÁ, J., ed.",
      },
      'Korandová, M., Česká Kubice DO 1960' => kora = {
         'name' => "Česká Kubice DO.",
         'rok'  =>  1960,
         'autor'=> "KORANDOVÁ, M."
      },
      'Korandová: Česká Kubice DO 1960' => kora,
      'Korandová. Česká Kubice DO 1960' => kora,
      'Korandová, Česká Kubice DO. 1960' => kora,
      'Obecná řeč v Nymburce' => {
        "name" => "Obecná řeč v Nymburce.",
        "rok" => 1885,
      }
    }

    examples_with_nazev2 = {
      'Baťha, Lidové výrazy, Naše řeč 1934' => batha = {
        "name"  => "Lidové výrazy.",
        "autor" => "BAŤHA, J.",
      },
      'Baťha, Lidové výrazy Naše řeč 1934' => batha,
      'Baťha, Lidové výrazy, Naše řeč' => batha,
      'Baťha, Lidové výrazy Naše řeč' => batha,
      'Baťha, Naše řeč' => batha,
    }

    examples.merge(examples_with_nazev2).each do |input, expectation|
      it "guesses correctly for #{input}" do
        source = Source.guess_source(input)

        expect(source).to be
        expect(source.attributes).to match(hash_including(expectation))
      end
    end
  end
end
