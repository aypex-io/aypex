FactoryBot.define do
  factory :favicon, class: Aypex::StoreFavicon do
    image do
      create(:favicon_asset)
    end

    before(:create) do |resource|
      if resource.store.nil?
        default_store = Aypex::Store.default.persisted? ? Aypex::Store.default : nil
        store = default_store || create(:store)

        resource.store = store
      end
    end
  end
end
