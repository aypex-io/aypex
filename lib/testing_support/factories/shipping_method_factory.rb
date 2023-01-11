FactoryBot.define do
  factory :base_shipping_method, class: Aypex::ShippingMethod do
    zones { |_a| [Aypex::Zone.global] }
    name { "UPS Ground" }
    code { "UPS_GROUND" }
    display_on { "both" }

    before(:create) do |shipping_method, _evaluator|
      if shipping_method.shipping_categories.empty?
        shipping_method.shipping_categories << (Aypex::ShippingCategory.first || create(:shipping_category))
      end
    end

    factory :shipping_method, class: Aypex::ShippingMethod do
      association(:calculator, factory: :shipping_calculator, strategy: :build)
    end

    factory :free_shipping_method, class: Aypex::ShippingMethod do
      association(:calculator, factory: :shipping_no_amount_calculator, strategy: :build)
    end
  end
end
