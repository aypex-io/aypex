FactoryBot.define do
  factory :store_logo, class: Aypex::StoreLogo do
    image do
      create(:asset_image)
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
