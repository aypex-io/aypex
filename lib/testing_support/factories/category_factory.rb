FactoryBot.define do
  factory :category, class: Aypex::Category do
    sequence(:name) { |n| "category_#{n}" }

    association :base_category, strategy: :create
    association :icon, factory: :category_image
    parent_id { base_category.root.id }
  end
end
