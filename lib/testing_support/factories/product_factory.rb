FactoryBot.define do
  factory :base_product, class: Aypex::Product do
    sequence(:name) { |n| "Product #{n}#{Kernel.rand(9999)}" }
    description { generate(:random_description) }
    price { 19.99 }
    cost_price { 17.00 }
    sku { generate(:sku) }
    available_on { 1.year.ago }
    make_active_at { 1.year.ago }
    deleted_at { nil }
    shipping_category { |r| Aypex::ShippingCategory.first || r.association(:shipping_category) }
    status { "active" }

    # ensure stock item will be created for this products master
    # also attach this product to the default store if no stores are passed in
    before(:create) do |product|
      create(:stock_location) unless Aypex::StockLocation.any?

      if product.stores.empty?
        default_store = Aypex::Store.default.persisted? ? Aypex::Store.default : nil
        store = default_store || create(:store)

        product.stores << [store]
      end
    end
    after(:create) do |product|
      Aypex::StockLocation.all.each { |stock_location| stock_location.propagate_variant(product.master) unless stock_location.stock_items.exists?(variant: product.master) }
    end

    factory :custom_product do
      name { "Custom Product" }
      price { 17.99 }

      tax_category { |r| Aypex::TaxCategory.first || r.association(:tax_category) }
    end

    factory :product do
      tax_category { |r| Aypex::TaxCategory.first || r.association(:tax_category) }

      factory :product_in_stock do
        after :create do |product|
          product.master.stock_items.first.adjust_count_on_hand(10)
        end

        trait :without_backorder do
          after :create do |product|
            product.master.stock_items.update_all(backorderable: false)
          end
        end
      end

      factory :product_with_option_types do
        after(:create) { |product| create(:product_option_type, product: product) }
      end
    end
  end
end
