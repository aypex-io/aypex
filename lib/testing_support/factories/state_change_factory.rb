FactoryBot.define do
  factory :state_change, class: Aypex::StateChange do
    stateful { build(:order) }
    previous_state { "cart" }
    next_state { "address" }
    user { build(:user) }
  end
end
