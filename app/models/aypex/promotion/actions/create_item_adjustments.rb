module Aypex
  class Promotion
    module Actions
      class CreateItemAdjustments < PromotionAction
        include Aypex::CalculatedAdjustments
        include Aypex::AdjustmentSource

        before_validation -> { self.calculator ||= Calculator::Promotion::PercentOnLineItem.new }

        def perform(options = {})
          order = options[:order]
          promotion = options[:promotion]

          create_unique_adjustments(order, order.line_items) do |line_item|
            promotion.line_item_actionable?(order, line_item)
          end
        end

        def compute_amount(line_item)
          order = line_item.order
          return 0 unless promotion.line_item_actionable?(order, line_item)

          matched_line_items = order.line_items.select do |li|
            promotion.line_item_actionable?(order, li)
          end

          ams = []
          matched_line_items.each do |i|
            next if i.equal?(matched_line_items.last)

            ams << i.amount
          end

          actionable_items_total = matched_line_items.sum(&:amount)
          last_actionable_item = matched_line_items.last

          options = {
            actionable_items_total:,
            last_actionable_item:,
            ams:
          }

          amounts = [line_item.amount, compute(line_item, **options)]
          amounts << (order.amount - order.adjustments.sum(:amount).abs) if order.adjustments.any?
          amounts.min * -1
        end
      end
    end
  end
end
