module Aypex
  class ReturnItem::EligibilityValidator::NoReimbursements < Aypex::ReturnItem::EligibilityValidator::BaseValidator
    def eligible_for_return?
      if Aypex::ReturnItem.where(inventory_unit: @return_item.inventory_unit).where.not(reimbursement_id: nil).any?
        add_error(:inventory_unit_reimbursed, Aypex.t("return_item_inventory_unit_reimbursed"))
        false
      else
        true
      end
    end

    def requires_manual_intervention?
      @errors.present?
    end
  end
end
