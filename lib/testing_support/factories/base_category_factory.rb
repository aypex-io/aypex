FactoryBot.define do
  factory :base_category, class: Aypex::BaseCategory do
    sequence(:name) { |n| "base_category_#{n}" }
    store { Aypex::Store.default }
  end
end
