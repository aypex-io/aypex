FactoryBot.define do
  factory :taxonomy, class: Aypex::Taxonomy do
    sequence(:name) { |n| "taxonomy_#{n}" }
    store { Aypex::Store.default }
  end
end
