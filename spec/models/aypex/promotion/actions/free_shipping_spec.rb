require "spec_helper"

describe Aypex::Promotion::Actions::FreeShipping do
  let(:order) { create(:completed_order_with_totals) }
  let(:promotion) { create(:promotion) }
  let(:action) { described_class.create }
  let(:payload) { {order:} }

  it_behaves_like "an adjustment source"

  # From promotion spec:
  describe "#perform" do
    before do
      order.shipments << create(:shipment)
      promotion.promotion_actions << action
    end

    it "creates a discount with correct negative amount" do
      expect(order.shipments.count).to eq(2)
      expect(order.shipments.first.cost).to eq(100)
      expect(order.shipments.last.cost).to eq(100)
      expect(action.perform(payload)).to be true
      expect(promotion.credits_count).to eq(2)
      expect(order.shipment_adjustments.count).to eq(2)
      expect(order.shipment_adjustments.first.amount.to_i).to eq(-100)
      expect(order.shipment_adjustments.last.amount.to_i).to eq(-100)
    end

    it "does not create a discount when order already has one from this promotion" do
      expect(action.perform(payload)).to be true
      expect(action.perform(payload)).to be false
      expect(promotion.credits_count).to eq(2)
      expect(order.shipment_adjustments.count).to eq(2)
    end
  end
end
