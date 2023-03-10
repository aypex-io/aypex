require "spec_helper"

describe Aypex::Stock::ContentItem do
  subject { described_class.new(inventory_unit) }

  let(:inventory_unit) { create(:inventory_unit, variant: variant) }
  let(:variant) { create(:variant, weight: 25.0) }

  describe "#volume" do
    it "calculate the total volume of the variant" do
      expect(subject.volume).to eq variant.volume * subject.quantity
    end
  end

  describe "#dimension" do
    it "calculate the total dimension of the variant" do
      expect(subject.dimension).to eq variant.dimension * subject.quantity
    end
  end

  describe "#amount" do
    it "calculates the amount based on line_item's price" do
      expect(subject.amount).to eq(inventory_unit.line_item.price * inventory_unit.quantity)
    end
  end
end
