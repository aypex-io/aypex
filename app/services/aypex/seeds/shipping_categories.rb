module Aypex
  module Seeds
    class ShippingCategories
      prepend Aypex::ServiceModule::Base

      def call
        Aypex::ShippingCategory.find_or_create_by!(name: I18n.t("aypex.seed.shipping.categories.default"))
        Aypex::ShippingCategory.find_or_create_by!(name: I18n.t("aypex.seed.shipping.categories.digital"))
      end
    end
  end
end
