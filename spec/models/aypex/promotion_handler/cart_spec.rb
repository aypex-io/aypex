require "spec_helper"

module Aypex
  module PromotionHandler
    describe Cart do
      subject { Cart.new(order, line_item) }

      let(:line_item) { create(:line_item) }
      let(:order) { line_item.order }

      let(:promotion) { create(:promotion, name: "At line items", stores: [order.store]) }
      let(:calculator) { Calculator::Promotion::PercentOnLineItem.new(percent: 10) }

      context "activates in LineItem level" do
        let!(:action) { Promotion::Actions::CreateItemAdjustments.create(promotion: promotion, calculator: calculator) }
        let(:adjustable) { line_item }

        shared_context "creates the adjustment" do
          it "creates the adjustment" do
            expect do
              subject.activate
            end.to change { adjustable.adjustments.count }.by(1)
          end
        end

        context "promotion with no rules" do
          include_context "creates the adjustment"
        end

        context "promotion includes item involved" do
          let!(:rule) { Promotion::Rules::Product.create(products: [line_item.product], promotion: promotion) }

          include_context "creates the adjustment"
        end

        context "promotion has item total rule" do
          let(:shirt) { create(:product, stores: [order.store]) }
          let!(:rule) { Promotion::Rules::ItemTotal.create(operator_min: "gt", amount_min: 50, operator_max: "lt", amount_max: 150, promotion: promotion) }

          before do
            # Makes the order eligible for this promotion
            order.item_total = 100
            order.save
          end

          include_context "creates the adjustment"
        end
      end

      context "activates promotions associated with the order" do
        let(:promo) { create(:promotion_with_item_adjustment, adjustment_rate: 5, code: "promo") }
        let(:adjustable) { line_item }

        before do
          order.promotions << promo
        end

        it "creates the adjustment" do
          expect do
            subject.activate
          end.to change { adjustable.adjustments.count }.by(1)
        end
      end
    end
  end
end
