require "spec_helper"

describe Aypex::ReturnItem::EligibilityValidator::TimeSincePurchase do
  let(:inventory_unit) { create(:inventory_unit, order: create(:shipped_order)) }
  let(:return_item) { create(:return_item, inventory_unit: inventory_unit) }
  let(:validator) { Aypex::ReturnItem::EligibilityValidator::TimeSincePurchase.new(return_item) }

  describe "#eligible_for_return?" do
    subject { validator.eligible_for_return? }

    context "it is within the return timeframe" do
      it "returns true" do
        completed_at = return_item.inventory_unit.order.completed_at - (return_item.inventory_unit.order.store.return_eligibility_number_of_days.days / 2)
        return_item.inventory_unit.order.update(completed_at: completed_at)
        expect(subject).to be true
      end
    end

    context "it is past the return timeframe" do
      before do
        completed_at = return_item.inventory_unit.order.completed_at - return_item.inventory_unit.order.store.return_eligibility_number_of_days.days - 1.day
        return_item.inventory_unit.order.update(completed_at: completed_at)
      end

      it "returns false" do
        expect(subject).to be false
      end

      it "sets an error" do
        subject
        expect(validator.errors[:number_of_days]).to eq I18n.t("aypex.return_item_time_period_ineligible")
      end
    end
  end
end
