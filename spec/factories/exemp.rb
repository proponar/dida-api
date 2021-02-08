FactoryBot.define do
  factory :exemp do
    kvalifikator { Faker::Lorem.word }
    vyznam { Faker::Lorem.word }
    # "meaning_id":46,
    #"rod":nil,
    rok { 1953 }
    exemplifikace { 'kanec se jinam nesmí střílet, jen do voka' }
    vetne { true }
    aktivni { true }
    zdroj_id { 1787 }
    # "zdroj_name":"Kladno 1–15.",
    # lokalizace_obec_id { 532576 }
    # lokalizace_cast_obce_id { nil }
    lokalizace_text { '' }
    urceni { nil }
    user
  end
end
