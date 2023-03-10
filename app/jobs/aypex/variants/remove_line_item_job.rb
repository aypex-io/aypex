module Aypex
  module Variants
    class RemoveLineItemJob < Aypex::BaseJob
      def perform(line_item:)
        Aypex::Dependency.cart_remove_line_item_service.constantize.call(order: line_item.order, line_item: line_item)
      end
    end
  end
end
