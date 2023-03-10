require "spec_helper"

describe Aypex::ReturnItem::EligibilityValidator::ReturnAuthorizationRequired do
  let(:return_item) { create(:return_item) }
  let(:validator) { Aypex::ReturnItem::EligibilityValidator::ReturnAuthorizationRequired.new(return_item) }

  describe "#eligible_for_return?" do
    subject { validator.eligible_for_return? }

    context "there is an rma on the return item" do
      it "returns true" do
        expect(subject).to be true
      end
    end

    context "there is no rma on the return item" do
      before { allow(return_item).to receive(:return_authorization).and_return(nil) }

      it "returns false" do
        expect(subject).to be false
      end

      it "sets an error" do
        subject
        expect(validator.errors[:rma_required]).to eq I18n.t("aypex.return_item_rma_ineligible")
      end
    end
  end
end
