module Aypex
  module Calculator::Promotion
    # FixedAmount
    #
    # Creates a fixed amount discount taken off
    # the actionable line items proportionally
    class FixedAmount < Calculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :amount, default: 0.0, null: false
        s.string :currency, default: "USD", null: false
      end

      def self.description
        I18n.t(:fixed_amount_line_items, scope: :aypex)
      end

      def compute(target_item = nil, **kwargs)
        actionable_items_total = kwargs[:actionable_items_total]
        last_actionable_item = kwargs[:last_actionable_item]
        ams = kwargs[:ams]

        # Return 0 if the following are not met.
        return 0 unless target_item && currency.casecmp(target_item.currency.upcase).zero?

        # If the order only has one item return the full amount, there is no need
        # for anything more complex to be carried out.
        return amount if target_item == last_actionable_item && ams.empty?

        # if there is more than one item in the order have the last applicable
        # line item eat the remainder of the discount, to pick up any rounding
        # errors from the previous items calculations. This ensures the adjustment
        # total always matched the specified amount.
        if target_item == last_actionable_item
          discounts_used = []
          ams.each do |i|
            percentage_of_applicable = (i / actionable_items_total)
            discounts_used << (amount * percentage_of_applicable).round(2)
          end
          amount - discounts_used.inject(:+)

        # else for most of the line items do the process below,
        # and also if it is the only applicable line item in the order.
        else
          percentage_of_applicable = (target_item.amount / actionable_items_total)
          (amount * percentage_of_applicable).round(2)
        end
      end
    end
  end
end
