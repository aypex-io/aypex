FactoryBot.define do
  factory :prototype, class: Aypex::Prototype do
    name { "Baseball Cap" }
    properties { [create(:property)] }
  end
  factory :prototype_with_option_types, class: Aypex::Prototype do
    name { "Baseball Cap" }
    properties { [create(:property)] }
    option_types { [create(:option_type)] }
  end
end
