FactoryBot.define do
  factory :wishlist, class: Aypex::Wishlist do
    user

    sequence(:name) { |n| "Wishlist_#{n}" }
    is_private { true }
    is_default { false }

    before(:create) do |wishlist|
      if wishlist.store.nil?
        default_store = Aypex::Store.default.persisted? ? Aypex::Store.default : nil
        store = default_store || create(:store)

        wishlist.store = store
      end
    end
  end
end
