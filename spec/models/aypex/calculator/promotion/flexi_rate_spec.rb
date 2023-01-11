require "spec_helper"

describe Aypex::Calculator::Promotion::FlexiRate do
  let(:calculator) { described_class.new }
  let(:order) { create(:order) }

  before { allow(order).to receive_messages quantity: 10 }

  context "compute" do
    it "computes amount correctly when all fees are 0" do
      expect(calculator.compute(order).round(2)).to eq(0.0)
    end

    it "computes amount correctly when first_item has a value" do
      allow(calculator).to receive_messages first_item: 1.0
      expect(calculator.compute(order).round(2)).to eq(1.0)
    end

    it "computes amount correctly when additional_items has a value" do
      allow(calculator).to receive_messages additional_item: 1.0
      expect(calculator.compute(order).round(2)).to eq(9.0)
    end

    it "computes amount correctly when additional_items and first_item have values" do
      allow(calculator).to receive_messages first_item: 5.0, additional_item: 1.0
      expect(calculator.compute(order).round(2)).to eq(14.0)
    end

    it "computes amount correctly when additional_items and first_item have values AND max items has value" do
      allow(calculator).to receive_messages first_item: 5.0, additional_item: 1.0, max_items: 3
      expect(calculator.compute(order).round(2)).to eq(7.0)
    end
  end
end
