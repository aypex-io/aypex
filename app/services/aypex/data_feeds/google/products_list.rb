module Aypex
  module DataFeeds
    module Google
      class ProductsList
        prepend Aypex::ServiceModule::Base

        def call(store)
          products = store.products.active
          success(products: products)
        end
      end
    end
  end
end
