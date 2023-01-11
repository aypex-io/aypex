FactoryBot.define do
  factory :payment_method, class: Aypex::PaymentMethod do
    type { "Aypex::PaymentMethod" }
    name { "Test" }

    before(:create) do |payment_method|
      if payment_method.stores.empty?
        default_store = Aypex::Store.default.persisted? ? Aypex::Store.default : nil
        store = default_store || create(:store)

        payment_method.stores << store
      end
    end
  end

  factory :check_payment_method, parent: :payment_method, class: Aypex::PaymentMethod::Check do
    type { "Aypex::PaymentMethod::Check" }
    name { "Check" }
  end

  factory :credit_card_payment_method, parent: :payment_method, class: Aypex::Gateway::Bogus do
    type { "Aypex::Gateway::Bogus" }
    name { "Credit Card" }
  end

  # authorize.net was moved to aypex_gateway.
  # Leaving this factory in place with bogus in case anyone is using it.
  factory :simple_credit_card_payment_method, parent: :payment_method, class: Aypex::Gateway::BogusSimple do
    type { "Aypex::Gateway::BogusSimple" }
    name { "Credit Card" }
  end

  factory :store_credit_payment_method, parent: :payment_method, class: Aypex::PaymentMethod::StoreCredit do
    type { "Aypex::PaymentMethod::StoreCredit" }
    name { "Store Credit" }
    description { "Store Credit" }
    active { true }
    auto_capture { true }
  end
end
