FactoryBot.define do
  factory :store_credit_category, class: Aypex::StoreCreditCategory do
    name { "Exchange" }
  end

  factory :store_credit_gift_card_category, class: Aypex::StoreCreditCategory do
    name { Aypex::StoreCreditCategory::GIFT_CARD_CATEGORY_NAME }
  end
end
