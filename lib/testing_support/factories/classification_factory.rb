FactoryBot.define do
  factory :classification, class: Aypex::Classification do
    product
    taxon

    position { 1 }
  end
end
