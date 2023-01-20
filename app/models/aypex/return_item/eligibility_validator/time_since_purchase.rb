module Aypex
  class ReturnItem::EligibilityValidator::TimeSincePurchase < Aypex::ReturnItem::EligibilityValidator::BaseValidator
    def eligible_for_return?
      if (@return_item.inventory_unit.order.completed_at + @return_item.inventory_unit.order.store.return_eligibility_number_of_days.days) > Time.current
        true
      else
        add_error(:number_of_days, I18n.t("aypex.return_item_time_period_ineligible"))
        false
      end
    end

    def requires_manual_intervention?
      false
    end
  end
end
