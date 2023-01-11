module Aypex
  module LineItems
    class FindByVariant
      def execute(order:, variant:, options: {})
        order.line_items.detect do |line_item|
          next unless line_item.variant_id == variant.id

          Aypex::Dependency.cart_compare_line_items_service.constantize.call(order: order, line_item: line_item, options: options).value
        end
      end
    end
  end
end
