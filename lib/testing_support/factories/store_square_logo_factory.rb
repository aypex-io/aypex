FactoryBot.define do
  factory :store_square_logo, class: Aypex::StoreSquareLogo do
    image do
      create(:asset_image_square)
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
