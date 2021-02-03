require 'rails_helper'

RSpec.describe Meaning, type: :model do
  let(:entry) { entry_with_meanings }
  let(:meaning) { entry.meanings[0] }

  describe '#json_hash' do
    it 'exists under a test entry' do
      expect(meaning).to be
    end

    it 'return a hash with kvalifikator and vyznam' do
      expect(meaning.json_hash).to have_key(:kvalifikator)
      expect(meaning.json_hash).to have_key(:vyznam)
    end
  end
end
