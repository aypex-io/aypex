FactoryBot.define do
  factory :calculator, class: Aypex::Calculator::Promotion::FlatRate do
    after(:create) { |c| c.amount = 10.0 }
  end

  factory :no_amount_calculator, class: Aypex::Calculator::Promotion::FlatRate do
    after(:create) { |c| c.amount = 0 }
  end

  factory :default_tax_calculator, class: Aypex::Calculator::Tax::Default do
  end

  factory :shipping_calculator, class: Aypex::Calculator::Shipping::FlatRate do
    after(:create) { |c| c.amount = 10.0 }
  end

  factory :shipping_no_amount_calculator, class: Aypex::Calculator::Shipping::FlatRate do
    after(:create) { |c| c.amount = 0 }
  end
end
