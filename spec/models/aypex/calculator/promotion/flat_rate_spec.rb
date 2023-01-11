require "spec_helper"

describe Aypex::Calculator::Promotion::FlatRate do
  let(:calculator) { described_class.new }
  let(:order) { create(:order) }

  before { allow(order).to receive_messages quantity: 10 }

  context "compute" do
    it "computes the amount as the rate when currency matches the order's currency" do
      calculator.amount = 25.0
      calculator.currency = "GBP"
      allow(order).to receive_messages currency: "GBP"
      expect(calculator.compute(order).round(2)).to eq(25.0)
    end

    it "computes the amount as 0 when currency does not match the order's currency" do
      calculator.amount = 100.0
      calculator.currency = "GBP"
      allow(order).to receive_messages currency: "USD"
      expect(calculator.compute(order).round(2)).to eq(0.0)
    end

    it "computes the amount as 0 when currency is blank" do
      calculator.amount = 100.0
      calculator.currency = ""
      allow(order).to receive_messages currency: "GBP"
      expect(calculator.compute(order).round(2)).to eq(0.0)
    end

    it "computes the amount as the rate when the currencies use different casing" do
      calculator.amount = 100.0
      calculator.currency = "gBp"
      allow(order).to receive_messages currency: "GBP"
      expect(calculator.compute(order).round(2)).to eq(100.0)
    end

    it "computes the amount as 0 when there is no object" do
      calculator.amount = 100.0
      calculator.currency = "GBP"
      expect(calculator.compute.round(2)).to eq(0.0)
    end
  end
end
