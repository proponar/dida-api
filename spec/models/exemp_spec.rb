require 'rails_helper'

RSpec.describe Exemp, type: :model do
  describe '#extract_urceni' do
    it 'extracts urceni' do
      expect(Exemp.extract_urceni("Słáf, ten by to moh v’eďeť, gdyž má mamu {bapkú, 7 sg.}")).
        to match([{'tvar'=>"bapkú", 'rod'=>" ", 'pad'=>"7s"}])
      expect(Exemp.extract_urceni("{bapka, 1 sg.} už je jako vjechítek")).
        to match([{'pad'=>"1s", 'rod'=>" ", 'tvar'=>"bapka"}])
    end
  end

  describe '#simplify_urceni' do
    it 'simplifies urceni' do
      expect(Exemp.simplify_urceni([{"pad" => "1p", "rod" => " ", "tvar" => "kočka"}])).to eq(101)
      expect(Exemp.simplify_urceni([{"pad" => "2s", "rod" => " ", "tvar" => "kočka"}])).to eq(2)
    end
  end
end
