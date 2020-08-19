FactoryBot.define do
  factory :source do
    #name { n = Faker::Lorem.unique.word; p n; n }
    sequence(:name) { |n| Faker::Lorem.word + n.to_s }
  end
end
