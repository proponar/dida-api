FactoryBot.define do
  factory :entry do
    user
    heslo { Faker::Lorem.unique.word }
  end

  factory :user
end
