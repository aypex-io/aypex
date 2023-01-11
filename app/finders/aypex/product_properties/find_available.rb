module Aypex
  module ProductProperties
    class FindAvailable
      include ProductFilterable

      def initialize(scope: ProductProperty.aypex_base_scopes, products_scope: Product.aypex_base_scopes)
        @scope = scope
        @products_scope = products_scope
      end

      def execute
        find_available(scope, products_scope)
      end

      private

      attr_reader :scope, :products_scope
    end
  end
end
