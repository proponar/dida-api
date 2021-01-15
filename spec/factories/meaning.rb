FactoryBot.define do
  factory :meaning do
    sequence(:cislo)
    kvalifikator { "bot." }
    vyznam { Faker::Lorem.word }
  end
end
