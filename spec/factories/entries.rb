FactoryBot.define do
  factory :entry do
    user
    heslo { Faker::Lorem.unique.word }
    druh { 0 }
    rod { 0 }
  end

  factory :user
end

def entry_with_meanings(meaning_count: 5)
  FactoryBot.create(:entry) do |e|
    FactoryBot.create_list(:meaning, meaning_count, entry: e)
  end
end

def entry_with_exemp
  FactoryBot.create(:entry) do |e|
    FactoryBot.create(:exemp, entry: e)
  end
end
