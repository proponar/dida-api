require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'self.guess_lokalizace' do

    examples = {
      'Držkov JH' => [nil, nil],
      'Držkov JN' => ["563561", nil],
      'Brno BM (Kohoutovice)' => ["582786", "411779"],
      'Světlá pod Ještědem LB' => ["564427", nil],
      'Světlá pod Ještědem LB (Hoření Paseky)' =>  ["564427", "160563"],
      'Žilov PM (Stýskaly)' => ["559709", "196959"],
      'Žinkovy PM' => ["558630", nil],
      'Ostrava OV' => ["554821", nil],
      'Ostrava OV (Antošovice)' => ["554821", "000396"],
      'Olbramice OV (Janovice)' => ["554049", "109789"],
    }

    examples.each do |input, expectation|
      it "guesses correctly for #{input}" do
        expect(Location.guess_lokalizace(input)).to match(expectation)
      end
    end
  end
end
