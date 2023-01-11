FactoryBot.define do
  factory :primary_credit_type, class: Aypex::StoreCreditType do
    name { Aypex::StoreCreditType::DEFAULT_TYPE_NAME }
    priority { "1" }
  end

  factory :store_credit_type, class: Aypex::StoreCreditType do
    name { Aypex::StoreCreditType::DEFAULT_TYPE_NAME }
    priority { "1" }
  end

  factory :secondary_credit_type, class: Aypex::StoreCreditType do
    name { "Non-expiring" }
    priority { "2" }
  end
end
