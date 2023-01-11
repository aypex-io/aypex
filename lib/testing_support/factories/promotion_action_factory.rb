FactoryBot.define do
  factory :promotion_action, class: Aypex::PromotionAction do
    association :promotion
  end
end
