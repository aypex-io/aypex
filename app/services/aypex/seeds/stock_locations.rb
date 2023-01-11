module Aypex
  module Seeds
    class StockLocations
      prepend Aypex::ServiceModule::Base

      def call
        country = Aypex::Store.default.default_country
        Aypex::StockLocation.find_or_create_by!(
          name: "default",
          propagate_all_variants: false,
          country: country,
          active: true,
          default: true
        )
      end
    end
  end
end
