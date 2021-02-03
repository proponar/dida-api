FactoryBot.define do
  factory :source do
    sequence(:name)   { |n| Faker::Lorem.word + n.to_s }
    sequence(:nazev2) { |n| Faker::Lorem.word + n.to_s }
    sequence(:autor)  { |n| Faker::Lorem.word + n.to_s }
    sequence(:cislo)
  end
end
