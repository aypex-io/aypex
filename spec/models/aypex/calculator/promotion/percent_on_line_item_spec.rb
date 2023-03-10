require "spec_helper"

describe Aypex::Calculator::Promotion::PercentOnLineItem do
  let(:calculator) { described_class.new }
  let(:line_item) { create(:line_item) }

  before { allow(calculator).to receive_messages percent: 10 }

  context "compute" do
    it "rounds result correctly" do
      allow(line_item).to receive_messages amount: 31.08
      expect(calculator.compute(line_item)).to eq 3.11

      allow(line_item).to receive_messages amount: 31.00
      expect(calculator.compute(line_item)).to eq 3.10
    end

    it "returns object.amount if computed amount is greater" do
      allow(line_item).to receive_messages amount: 30.00
      allow(calculator).to receive_messages percent: 110

      expect(calculator.compute(line_item)).to eq 30.0
    end
  end
end
