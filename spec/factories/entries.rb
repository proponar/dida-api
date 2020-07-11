FactoryBot.define do
  factory :entry do
    heslo { Faker::Lorem.word }
  end
end
