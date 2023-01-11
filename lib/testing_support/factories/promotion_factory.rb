FactoryBot.define do
  trait :with_item_total_rule do
    transient do
      item_total_threshold_amount { 10 }
    end

    after(:create) do |promotion, evaluator|
      rule = Aypex::Promotion::Rules::ItemTotal.create!(
        operator_min: "gte",
        operator_max: "lte",
        amount_min: evaluator.item_total_threshold_amount,
        amount_max: evaluator.item_total_threshold_amount + 100
      )
      promotion.rules << rule
      promotion.save!
    end
  end

  factory :promotion, class: Aypex::Promotion do
    name { "Promo" }

    before(:create) do |promotion, _evaluator|
      if promotion.stores.empty?
        default_store = Aypex::Store.default.persisted? ? Aypex::Store.default : nil
        store = default_store || create(:store)

        promotion.stores << [store]
      end
    end

    trait :with_line_item_adjustment do
      transient do
        adjustment_rate { 10 }
      end

      after(:create) do |promotion, evaluator|
        calculator = Aypex::Calculator::Promotion::FlatRate.new
        calculator.amount = evaluator.adjustment_rate
        Aypex::Promotion::Actions::CreateItemAdjustments.create!(calculator: calculator, promotion: promotion)
      end
    end

    trait :with_one_use_per_user_rule do
      after(:create) do |promotion|
        rule = Aypex::Promotion::Rules::OneUsePerUser.create!
        promotion.rules << rule
      end
    end

    factory :promotion_with_item_adjustment, traits: [:with_line_item_adjustment]
    factory :promotion_with_one_use_per_user_rule, traits: [:with_line_item_adjustment, :with_one_use_per_user_rule]
    factory :promotion_with_item_total_rule, traits: [:with_item_total_rule]

    factory :free_shipping_promotion do
      name { "Free Shipping Promotion" }

      after(:create) do |promotion|
        action = Aypex::Promotion::Actions::FreeShipping.new
        action.promotion = promotion
        action.save
      end

      factory :free_shipping_promotion_with_item_total_rule, traits: [:with_item_total_rule]
    end
  end
end
