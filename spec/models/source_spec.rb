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
#cislo,autor,name,nazev2,typ,rok_sberu,lokalizace,lokalizace_text
1000001,"ADÁMEK, K. V.",Lid na Hlinecku.,,Kniha,1900,1891,,
1000002,"AMBROŽ, J.",Telč JI.,,Excerpta,1969,1969,Telč JI,
1000007,"AMBROŽ, J.",Telč JI.,,Excerpta,1970,1970,Telč JI,
1000009,"AMBROŽ, J.",Telč JI.,,Excerpta,1966,1966,Telč JI,
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
