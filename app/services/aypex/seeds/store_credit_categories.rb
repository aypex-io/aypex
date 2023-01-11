module Aypex
  module Seeds
    class StoreCreditCategories
      prepend Aypex::ServiceModule::Base

      def call
        # FIXME: we should use translations here
        Aypex::StoreCreditCategory.find_or_create_by!(name: "Default")
        Aypex::StoreCreditCategory.find_or_create_by!(name: "Non-expiring")
        Aypex::StoreCreditCategory.find_or_create_by!(name: "Expiring")
      end
    end
  end
end
