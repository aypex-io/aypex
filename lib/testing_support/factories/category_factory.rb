FactoryBot.define do
  factory :category, class: Aypex::Category do
    sequence(:name) { |n| "category_#{n}" }

    association :base_category, strategy: :create
    association :image, strategy: :create
    parent_id { base_category.root.id }
  end
end
