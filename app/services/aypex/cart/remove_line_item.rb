module Aypex
  module Cart
    class RemoveLineItem
      prepend Aypex::ServiceModule::Base

      def call(order:, line_item:, options: nil)
        options ||= {}
        ActiveRecord::Base.transaction do
          line_item.destroy!
          Aypex::Dependency.cart_recalculate_service.constantize.new.call(
            order: order,
            line_item: line_item,
            options: options
          )
        end
        order.reload
        success(line_item)
      end
    end
  end
end
