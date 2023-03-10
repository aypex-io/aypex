module Aypex
  class ReturnItem::EligibilityValidator::OrderCompleted < Aypex::ReturnItem::EligibilityValidator::BaseValidator
    def eligible_for_return?
      if @return_item.inventory_unit.order.completed?
        true
      else
        add_error(:order_not_completed, I18n.t("aypex.return_item_order_not_completed"))
        false
      end
    end

    def requires_manual_intervention?
      false
    end
  end
end
