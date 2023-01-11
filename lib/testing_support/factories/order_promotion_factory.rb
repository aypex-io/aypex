FactoryBot.define do
  factory :order_promotion, class: Aypex::OrderPromotion do
    order
    promotion
  end
end
