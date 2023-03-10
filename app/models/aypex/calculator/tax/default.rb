require_dependency "aypex/calculator"

module Aypex
  module Calculator::Tax
    class Default < Calculator
      include VatPriceCalculation

      def self.description
        I18n.t(:default_tax, scope: :aypex)
      end

      def compute_order(order)
        matched_line_items = order.line_items.select do |line_item|
          line_item.tax_category == rate.tax_category
        end

        line_items_total = matched_line_items.sum(&:total)
        if rate.included_in_price
          round_to_two_places(line_items_total - (line_items_total / (1 + rate.amount)))
        else
          round_to_two_places(line_items_total * rate.amount)
        end
      end

      # When it comes to computing shipments or line items: same same.
      def compute_shipment_or_line_item(item)
        if rate.included_in_price
          deduced_total_by_rate(item.pre_tax_amount, rate)
        else
          round_to_two_places(item.discounted_amount * rate.amount)
        end
      end

      alias_method :compute_shipment, :compute_shipment_or_line_item
      alias_method :compute_line_item, :compute_shipment_or_line_item

      def compute_shipping_rate(shipping_rate)
        if rate.included_in_price
          pre_tax_amount = shipping_rate.cost / (1 + rate.amount)
          deduced_total_by_rate(pre_tax_amount, rate)
        else
          with_tax_amount = shipping_rate.cost * rate.amount
          round_to_two_places(with_tax_amount)
        end
      end

      private

      def rate
        calculable
      end

      def deduced_total_by_rate(pre_tax_amount, rate)
        round_to_two_places(pre_tax_amount * rate.amount)
      end
    end
  end
end
