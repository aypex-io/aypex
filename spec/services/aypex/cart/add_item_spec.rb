require "spec_helper"

module Aypex
  describe Cart::AddItem do
    subject { described_class }

    let(:order) { create(:order) }
    let(:variant) { create(:variant, price: 20) }
    let(:qty) { 1 }
    let(:execute) { subject.call(order: order, variant: variant, quantity: qty) }
    let(:value) { execute.value }
    let(:expected_line_item) { order.reload.line_items.first }

    context "add line item to order" do
      it "change by one and recalculate amount" do
        expect { execute }.to change { order.line_items.count }.by(1)
        expect(execute).to be_success
        expect(value).to eq expected_line_item
        expect(order.amount).to eq 20
      end
    end

    context "with same line item" do
      let(:line_item) { create(:line_item, variant: variant) }
      let(:order) { create(:order, line_items: [line_item]) }

      it "not to add" do
        expect(execute).to be_success
        expect(value).to eq expected_line_item
        expect(order.line_items.count).to eq 1
      end
    end

    context "with given shipment" do
      let(:shipment) { create(:shipment) }
      let(:options) { {shipment: shipment} }
      let(:execute) { subject.call(order: order, variant: variant, quantity: qty, options: options) }

      it "ensure shipment calls update_amounts instead of order calling ensure_updated_shipments" do
        expect(order).to receive(:refresh_shipment_rates).with(Aypex::ShippingMethod::DISPLAY_ON_BACK_END)
        expect(order).not_to receive(:ensure_updated_shipments)
        expect(shipment).to receive(:update_amounts)
        expect(execute).to be_success
      end
    end

    context "not given a shipment" do
      let(:execute) { subject.call(order: order, variant: variant, quantity: qty) }

      it "ensures updated shipments" do
        expect(order).to receive(:ensure_updated_shipments)
        expect(execute).to be_success
      end
    end

    context "with store_credits payment" do
      let!(:payment) { create(:store_credit_payment, order: order) }
      let(:execute) { subject.call(order: order, variant: variant, quantity: 1) }

      it do
        expect { execute }.to change { order.payments.store_credits.count }.by(-1)
      end
    end

    context "running promotions" do
      let(:promotion) { create(:promotion) }
      let(:calculator) { Aypex::Calculator::Promotion::FlatRate.new(amount: 10) }

      context "one active line item promotion" do
        let!(:action) { Aypex::Promotion::Actions::CreateItemAdjustments.create(promotion: promotion, calculator: calculator) }

        before do
          subject.call(order: order, variant: variant, quantity: 1)
          order.reload
        end

        it "creates valid discount on order" do
          subject.call(order: order, variant: variant, quantity: 1)
          expect(order.line_item_adjustments.to_a.sum(&:amount)).not_to eq 0
          expect(order.total).to eq 30
        end
      end

      context "VAT for variant with percent promotion" do
        let!(:category) { Aypex::TaxCategory.create name: "Taxable Foo" }
        let!(:rate) do
          Aypex::TaxRate.create(
            name: "Tax Rate 1",
            amount: 0.25,
            included_in_price: true,
            calculator: Aypex::Calculator::Tax::Default.create,
            tax_category: category,
            zone: create(:zone_with_country, default_tax: true)
          )
        end
        let(:variant) { create(:variant, price: 1000) }
        let(:calculator) { Aypex::Calculator::Promotion::PercentOnLineItem.new(percent: 50) }
        let!(:action) { Aypex::Promotion::Actions::CreateItemAdjustments.create(promotion: promotion, calculator: calculator) }

        it "updates included_tax_total" do
          expect(order.included_tax_total.to_f).to eq(0.00)
          subject.call(order: order, variant: variant, quantity: 1)
          expect(order.included_tax_total.to_f).to eq(100)
        end

        it "updates included_tax_total after adding two line items" do
          subject.call(order: order, variant: variant, quantity: 1)
          expect(order.included_tax_total.to_f).to eq(100)
          subject.call(order: order, variant: variant, quantity: 1)
          expect(order.included_tax_total.to_f).to eq(200)
        end
      end
    end

    context "pass valid params hash in options" do
      let(:options) { {quantity: 2, variant_id: variant.id} }
      let(:execute) { subject.call(order: order, variant: variant, quantity: nil, options: options) }

      it do
        expect(execute).to be_success
        expect(order.line_items.count).to eq 1
        line_item = order.line_items.first
        expect(line_item.quantity).to eq 2
      end
    end

    context "pass invalid arguments" do
      context "different quantity in argument and in options" do
        let(:options) { {quantity: 2} }
        let(:execute) { subject.call(order: order, variant: variant, quantity: 3, options: options) }

        it "take value from options" do
          expect(execute).to be_success
          line_item = order.line_items.first
          expect(line_item.quantity).to eq 2
        end
      end

      context "different quantity no quantity in argument and in params" do
        let(:options) { {} }
        let(:execute) { subject.call(order: order, variant: variant, quantity: nil, options: options) }

        it "set default" do
          expect(execute).to be_success
          line_item = order.line_items.first
          expect(line_item.quantity).to eq 1
        end
      end

      context "not permitted" do
        let(:options) { {dummy_param: true} }
        let(:execute) { subject.call(order: order, variant: variant, quantity: 1, options: options) }

        it do
          expect(execute).to be_success
          line_item = order.line_items.first
          expect(line_item.quantity).to eq 1
        end
      end

      context "pass non-existing variant" do
        let(:variant_2) { create(:variant) }
        let(:execute) { subject.call(order: order, variant: variant_2, quantity: 1) }

        before { Aypex::Variant.find(variant_2.id).destroy }

        it do
          expect(execute).to be_failure
          order.reload
          expect(order.line_items.count).to eq 0
        end
      end

      context "variant have not desired quantity" do
        let(:execute) { subject.call(order: order, variant: variant, quantity: 10) }

        before { variant.stock_items.first.update backorderable: false }

        it do
          expect(execute).to be_failure
          order.reload
          expect(order.line_items.count).to eq 0
        end
      end

      context "variant has been descontinued" do
        let(:variant) { create(:variant, discontinue_on: 1.day.ago) }
        let(:execute) { subject.call(order: order, variant: variant, quantity: 10) }

        it do
          expect(execute).to be_failure
          order.reload
          expect(order.line_items.count).to eq 0
        end
      end
    end

    context "setting metadata" do
      let(:public_metadata) { {"prop1" => "value1"} }
      let(:private_metadata) { {"prop2" => "value2"} }
      let(:execute) { subject.call(order: order, variant: variant, quantity: qty, public_metadata: public_metadata, private_metadata: private_metadata) }

      context "private metadata" do
        it do
          expect(execute).to be_success
          order.reload
          expect(order.line_items.first.private_metadata).to eq private_metadata
        end
      end

      context "public metadata" do
        it do
          expect(execute).to be_success
          order.reload
          expect(order.line_items.first.public_metadata).to eq public_metadata
        end
      end
    end
  end
end
