FactoryBot.define do
  factory :shipping_category, class: Aypex::ShippingCategory do
    sequence(:name) { |n| "ShippingCategory #{n}" }
  end
end
