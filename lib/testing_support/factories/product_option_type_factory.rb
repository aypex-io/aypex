FactoryBot.define do
  factory :product_option_type, class: Aypex::ProductOptionType do
    product
    option_type
  end
end
