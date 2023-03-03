module Aypex
  module Seeds
    class StoreCreditCategories
      prepend Aypex::ServiceModule::Base

      def call
        Aypex::StoreCreditCategory.find_or_create_by!(name: I18n.t("aypex.default"))
        Aypex::StoreCreditCategory.find_or_create_by!(name: I18n.t("aypex.none_expiring"))
        Aypex::StoreCreditCategory.find_or_create_by!(name: I18n.t("aypex.expiring"))
      end
    end
  end
end
