FactoryBot.define do
  factory :shipping_rate, class: Aypex::ShippingRate do
    cost { BigDecimal("10") }
    shipping_method
    shipment
  end
end
