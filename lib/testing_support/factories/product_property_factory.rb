FactoryBot.define do
  factory :product_property, class: Aypex::ProductProperty do
    product { create(:product, stores: [create(:store)]) }
    value { "val-#{rand(50)}" }
    property
  end
end
