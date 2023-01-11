FactoryBot.define do
  factory :promotion_rule, class: Aypex::PromotionRule do
    association :promotion
  end
end
