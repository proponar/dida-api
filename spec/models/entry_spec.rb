require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe '#import_text' do
    let(:user) { User.create(name: 'martin') }
    let(:entry) {
      Entry.create(
        user: user,
        heslo: Faker::Lorem.word,
        rod: Entry.map_rod('m'),
        druh: Entry.map_druh('adj')
      )
    }

    let(:meaning) {
      Meaning.create(cislo: 1, kvalifikator: Faker::Lorem.word, vyznam: Faker::Lorem.word, entry: entry)
    }

    it 'parses lokalizace' do
      jelen_test_data = <<EOD
(1 sg.) spravne jelen se promňeňi f krásního koňe; Světlá pod Ještědem LB; ČJA Dodatky.
(1 sg.) spravne jelen se promňeňi f krásního koňe; Světlá pod Ještědem LB (Hoření Paseky); ČJA Dodatky.
(1 sg.) blbe jelen se promňeňi f krásního koňe; Světlá pod Ještědem LB (Hoření Paseky Blbost); ČJA Dodatky.
(1 sg.) blbe jelen se promňeňi f krásního koňe; Světlá pod Ještědem LX (Hoření Paseky); ČJA Dodatky.
EOD
      result = entry.import_text(user, jelen_test_data, meaning.id, true, true)
      expect(result.length).to eq(4)

      expect(result[0].lokalizace_obec).to eq(564427)
      expect(result[0].lokalizace_cast_obce).to be_nil
      expect(result[0].lokalizace_text).to eq('')

      expect(result[1].lokalizace_obec).to eq(564427)
      expect(result[1].lokalizace_cast_obce).to eq(160563)
      expect(result[1].lokalizace_text).to eq('')

      expect(result[2].lokalizace_obec).to be_nil
      expect(result[2].lokalizace_cast_obce).to be_nil
      expect(result[2].lokalizace_text).to eq('Světlá pod Ještědem LB (Hoření Paseky Blbost)')

      expect(result[3].lokalizace_obec).to be_nil
      expect(result[3].lokalizace_cast_obce).to be_nil
      expect(result[3].lokalizace_text).to eq('Světlá pod Ještědem LX (Hoření Paseky)')
    end

    it 'parses all problematic "zkratka okresu"' do
      # První příklad je Plzeň-sever, druhý Plzeň-jih
      plzen_test_data = <<EOD
stála tam {husa, 1 sg.} a mlčela; Žilov PM (Stýskaly); Šembera, Základové
stála tam {husa, 1 sg.} a mlčela; Žinkovy PM; Šembera, Základové
EOD

      # Nerozpoznává nic z okresu Ostrava (OV). Např.:
      ostrava_test_data = <<EOD
stála tam {husa, 1 sg.} a mlčela; Ostrava OV; Šembera, Základové
stála tam {husa, 1 sg.} a mlčela; Ostrava OV (Antošovice); Šembera, Základové
stála tam {husa, 1 sg.} a mlčela; Olbramice OV (Janovice); Šembera, Základové
EOD

      result = entry.import_text(user, plzen_test_data + ostrava_test_data, meaning.id, true, true)
      expect(result.find_all { |r| r.lokalizace_obec.present? }.length).to eq(5)
    end

    it 'parses source w/o an autor and the location' do
      result = entry.import_text(
        user,
        "stála tam {husa, 1 sg.} a mlčela; Nymburk NB; Obecná řeč v Nymburce",
        meaning.id, true, true
      )[0]

      expect(result.lokalizace_obec).to eq(537004)
      expect(result.source.name).to eq("Obecná řeč v Nymburce.")
    end
  end
end
