require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe '#import_text' do

    it 'parses lokalizace' do
      entry = Entry.create(
        user: user = User.create(name: 'martin'),
        heslo: Faker::Lorem.word,
        rod: Entry.map_rod('m'),
        druh: Entry.map_druh('adj')
      )
      meaning = Meaning.create(cislo: 1, kvalifikator: Faker::Lorem.word, vyznam: Faker::Lorem.word, entry: entry)

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
  end
end
