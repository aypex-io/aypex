module Aypex
  module Variants
    class RemoveLineItems
      prepend Aypex::ServiceModule::Base

      def call(variant:)
        variant.line_items.joins(:order).where.not(aypex_orders: {state: "complete"}).find_each do |line_item|
          Aypex::Variants::RemoveLineItemJob.perform_later(line_item: line_item)
        end

        success(true)
      end
    end
  end
end
