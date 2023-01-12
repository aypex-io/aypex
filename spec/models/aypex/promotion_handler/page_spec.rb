require "spec_helper"

module Aypex
  module PromotionHandler
    describe Page do
      let(:order) { create(:order_with_line_items, line_items_count: 1) }

      let(:promotion) { create(:promotion, name: "10% off", path: "10off", stores: [order.store]) }

      before do
        calculator = Calculator::Promotion::PercentOnLineItem.new(percent: 10)
        action = Promotion::Actions::CreateItemAdjustments.create(calculator: calculator)
        promotion.actions << action
      end

      it "activates at the right path" do
        expect(order.line_item_adjustments.count).to eq(0)
        Aypex::PromotionHandler::Page.new(order, "10off").activate
        expect(order.line_item_adjustments.count).to eq(1)
      end

      context "when promotion is expired" do
        before do
          promotion.update_columns(
            starts_at: 1.week.ago,
            expires_at: 1.day.ago
          )
        end

        it "is not activated" do
          expect(order.line_item_adjustments.count).to eq(0)
          Aypex::PromotionHandler::Page.new(order, "10off").activate
          expect(order.line_item_adjustments.count).to eq(0)
        end
      end

      it "does not activate at the wrong path" do
        expect(order.line_item_adjustments.count).to eq(0)
        Aypex::PromotionHandler::Page.new(order, "wrongpath").activate
        expect(order.line_item_adjustments.count).to eq(0)
      end
    end
  end
end
