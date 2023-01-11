module Aypex
  module Seeds
    class All
      prepend Aypex::ServiceModule::Base

      def call
        # GEO
        Countries.call
        States.call
        Zones.call

        # user roles
        Roles.call

        # additional data
        DefaultReimbursementTypes.call
        ShippingCategories.call
        StoreCreditCategories.call

        # store & stock location
        Stores.call
        StockLocations.call
      end
    end
  end
end
