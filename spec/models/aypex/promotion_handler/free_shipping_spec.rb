require "spec_helper"

module Aypex
  module PromotionHandler
    describe FreeShipping do
      subject { Aypex::PromotionHandler::FreeShipping.new(order) }

      let(:order) { create(:order) }
      let(:shipment) { create(:shipment, order: order) }

      let(:promotion) { create(:promotion, name: "Free Shipping", stores: [order.store]) }
      let(:calculator) { Calculator::FlatPercentItemTotal.new(flat_percent: 10) }
      let!(:action) { Promotion::Actions::FreeShipping.create(promotion: promotion) }

      context "activates in Shipment level" do
        it "creates the adjustment" do
          expect { subject.activate }.to change { shipment.adjustments.count }.by(1)
        end
      end

      context "if promo has a code" do
        before do
          promotion.update_column(:code, "code")
        end

        it "does adjust the shipment when applied to order" do
          order.promotions << promotion

          expect { subject.activate }.to change { shipment.adjustments.count }
        end

        it "does not adjust the shipment when not applied to order" do
          expect { subject.activate }.not_to change { shipment.adjustments.count }
        end
      end

      context "if promo has a path" do
        before do
          promotion.update_column(:path, "path")
        end

        it "does not adjust the shipment" do
          expect { subject.activate }.not_to change { shipment.adjustments.count }
        end
      end
    end
  end
end
