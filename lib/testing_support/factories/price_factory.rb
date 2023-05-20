FactoryBot.define do
  factory :price, class: Aypex::Price do
    variant
    amount { 19.99 }
    currency { "AED" }
  end
end
