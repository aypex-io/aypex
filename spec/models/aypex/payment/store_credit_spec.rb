require "spec_helper"

describe "Payment" do
  describe "#cancel!" do
    subject { payment.cancel! }

    let(:store) { create(:store) }

    context "a store credit" do
      let(:store_credit) { create(:store_credit, amount_used: captured_amount, store: store) }
      let(:auth_code) { "1-SC-20141111111111" }
      let(:captured_amount) { 10.0 }
      let(:order) { create(:order, store: store) }
      let(:payment) { create(:store_credit_payment, response_code: auth_code, order: order) }

      let!(:capture_event) do
        create(:store_credit_auth_event,
          action: Aypex::StoreCredit::CAPTURE_ACTION,
          authorization_code: auth_code,
          amount: captured_amount,
          store_credit: store_credit)
      end

      let(:successful_response) do
        ActiveMerchant::Billing::Response.new(
          true,
          I18n.t("aypex.store_credit_payment_method.successful_action", action: :cancel),
          {},
          authorization: payment.response_code
        )
      end

      let(:failed_response) do
        ActiveMerchant::Billing::Response.new(
          false,
          I18n.t("aypex.store_credit_payment_method.unable_to_find_for_action", action: :cancel,
            auth_code: payment.response_code),
          {},
          {}
        )
      end

      it "attempts to cancels the payment" do
        expect(payment.payment_method).to receive(:cancel).with(payment.response_code, payment) { successful_response }
        subject
      end

      context "cancels successfully" do
        it "voids the payment", retry: 3 do
          expect { subject }.to change(payment, :state).to("void")
        end
      end

      context "does not cancel successfully" do
        it "does not change the payment state" do
          expect(payment.payment_method).to receive(:cancel).with(payment.response_code, payment) { failed_response }
          expect { subject }.to raise_error(Aypex::GatewayError)
          expect(payment.reload.state).not_to eq "void"
        end
      end
    end
  end
end
