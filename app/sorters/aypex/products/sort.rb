module Aypex
  module Products
    class Sort < ::Aypex::BaseSorter
      def initialize(scope, current_currency, params = {}, allowed_sort_attributes = [])
        super(scope, params, allowed_sort_attributes)
        @currency = params[:currency] || current_currency
      end

      def call
        products = by_param_attributes(scope)
        products = by_price(products)
        products = by_sku(products)

        products.distinct
      end

      private

      attr_reader :sort, :scope, :currency, :allowed_sort_attributes

      def by_price(scope)
        return scope unless (value = sort_by?("price"))

        scope.joins(master: :prices)
          .select("#{Aypex::Product.table_name}.*, #{Aypex::Price.table_name}.amount")
          .distinct
          .where(aypex_prices: {currency: currency})
          .order("#{Aypex::Price.table_name}.amount #{value[1]}")
      end

      def by_sku(scope)
        return scope unless (value = sort_by?("sku"))

        select_product_attributes = if scope.to_sql.include?("#{Aypex::Product.table_name}.*")
          ""
        else
          "#{Aypex::Product.table_name}.*, "
        end

        scope.joins(:master)
          .select("#{select_product_attributes}#{Aypex::Variant.table_name}.sku")
          .where(Aypex::Variant.table_name.to_s => {is_master: true})
          .order("#{Aypex::Variant.table_name}.sku #{value[1]}")
      end

      def sort_by?(field)
        sort.detect { |s| s[0] == field }
      end
    end
  end
end
