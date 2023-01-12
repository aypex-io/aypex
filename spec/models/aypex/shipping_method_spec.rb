require "spec_helper"

class DummyShippingCalculator < Aypex::ShippingCalculator
end

describe Aypex::ShippingMethod do
  let(:shipping_method) { create(:shipping_method) }
  let(:frontend_shipping_method) { create(:shipping_method, display_on: "front_end") }
  let(:admin_shipping_method) { create(:shipping_method, display_on: "back_end") }
  let(:front_and_back_end_shipping_method) { create(:shipping_method, display_on: "both") }

  it_behaves_like "metadata"

  context "calculators" do
    it "rejects calculators that don't inherit from Aypex::ShippingCalculator" do
      allow(Aypex::ShippingMethod).to receive_message_chain(:aypex_calculators, :shipping_methods).and_return([
        Aypex::Calculator::Shipping::FlatPercentItemTotal,
        Aypex::Calculator::Shipping::PriceSack,
        Aypex::Calculator::Tax::Default,
        DummyShippingCalculator # included as regression test for https://github.com/aypex/aypex/issues/3109
      ])

      expect(Aypex::ShippingMethod.calculators).to eq([Aypex::Calculator::Shipping::FlatPercentItemTotal, Aypex::Calculator::Shipping::PriceSack, DummyShippingCalculator])
      expect(Aypex::ShippingMethod.calculators).not_to eq([Aypex::Calculator::Tax::Default])
    end
  end

  # Regression test for #4492
  describe "#shipments" do
    let!(:shipping_method) { create(:shipping_method) }
    let!(:shipment) do
      shipment = create(:shipment)
      shipment.shipping_rates.create!(shipping_method: shipping_method)
      shipment
    end

    it "can gather all the related shipments" do
      expect(shipping_method.shipments).to include(shipment)
    end
  end

  context "validations" do
    it "validates presence of name" do
      subject.valid?
      expect(subject.errors.messages[:name].size).to eq(1)
    end

    it "validates presence of display_on" do
      subject.valid?
      expect(subject.errors.messages[:display_on].size).to eq(1)
    end

    context "shipping category" do
      context "is required" do
        before { subject.valid? }

        it { expect(subject.errors.messages[:base].size).to eq(1) }

        it "adds error to base" do
          expect(subject.errors.messages[:base]).to include(I18n.t(:required_shipping_category,
            scope: [
              :activerecord, :errors, :models,
              "aypex/shipping_method", :attributes, :base
            ]))
        end
      end

      context "one associated" do
        before { subject.shipping_categories.push(create(:shipping_category)) }

        it { expect(subject.errors.messages[:base]).to be_empty }
      end
    end
  end

  context "factory" do
    it "sets calculable correctly" do
      expect(shipping_method.calculator.calculable).to eq(shipping_method)
    end
  end

  context "generating tracking URLs" do
    context "shipping method has a tracking URL mask on file" do
      let(:tracking_url) { "https://track-o-matic.com/:tracking" }

      before { allow(subject).to receive(:tracking_url) { tracking_url } }

      context "tracking number has spaces" do
        let(:tracking_numbers) { ["1234 5678 9012 3456", "a bcdef"] }
        let(:expectations) { %w[https://track-o-matic.com/1234%205678%209012%203456 https://track-o-matic.com/a%20bcdef] }

        it "returns a single URL with '%20' in lieu of spaces" do
          tracking_numbers.each_with_index do |num, i|
            expect(subject.build_tracking_url(num)).to eq(expectations[i])
          end
        end
      end
    end
  end

  # Regression test for #4320
  context "soft deletion" do
    let(:shipping_method) { create(:shipping_method) }

    it "soft-deletes when destroy is called" do
      shipping_method.destroy
      expect(shipping_method.deleted_at).not_to be_blank
    end
  end

  describe "#available_to_display?" do
    context "when available on frontend" do
      it { expect(frontend_shipping_method.available_to_display?(Aypex::ShippingMethod::DISPLAY_ON_FRONT_END)).to be true }
      it { expect(admin_shipping_method.available_to_display?(Aypex::ShippingMethod::DISPLAY_ON_FRONT_END)).to be false }
      it { expect(front_and_back_end_shipping_method.available_to_display?(Aypex::ShippingMethod::DISPLAY_ON_FRONT_END)).to be true }
    end

    context "when available on admin" do
      it { expect(frontend_shipping_method.available_to_display?(Aypex::ShippingMethod::DISPLAY_ON_BACK_END)).to be false }
      it { expect(admin_shipping_method.available_to_display?(Aypex::ShippingMethod::DISPLAY_ON_BACK_END)).to be true }
      it { expect(front_and_back_end_shipping_method.available_to_display?(Aypex::ShippingMethod::DISPLAY_ON_BACK_END)).to be true }
    end
  end

  describe "#frontend?" do
    it { expect(frontend_shipping_method.send(:frontend?)).to be true }
    it { expect(admin_shipping_method.send(:frontend?)).to be false }
    it { expect(front_and_back_end_shipping_method.send(:frontend?)).to be true }
  end

  describe "#backend?" do
    it { expect(frontend_shipping_method.send(:backend?)).to be false }
    it { expect(admin_shipping_method.send(:backend?)).to be true }
    it { expect(front_and_back_end_shipping_method.send(:backend?)).to be true }
  end
end
