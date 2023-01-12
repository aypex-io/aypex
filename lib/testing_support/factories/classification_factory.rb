FactoryBot.define do
  factory :classification, class: Aypex::Classification do
    product
    category

    position { 1 }
  end
end
