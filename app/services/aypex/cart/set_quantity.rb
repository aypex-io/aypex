module Aypex
  module Cart
    class SetQuantity
      prepend Aypex::ServiceModule::Base

      def call(order:, line_item:, quantity: nil)
        ActiveRecord::Base.transaction do
          run :change_item_quantity
          run Aypex::Dependency.cart_recalculate_service.constantize
        end
      end

      private

      def change_item_quantity(order:, line_item:, quantity: nil)
        return failure(line_item) unless line_item.update(quantity: quantity)

        success(order: order, line_item: line_item)
      end
    end
  end
end
