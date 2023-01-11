FactoryBot.define do
  factory :menu, class: Aypex::Menu do
    name { generate(:random_string) }
    locale { "en" }
    location { "Header" }

    before(:create) do |menu|
      if menu.store.nil?
        default_store = Aypex::Store.default.persisted? ? Aypex::Store.default : nil
        store = default_store || create(:store)

        menu.store = store
      end
    end
  end
end
