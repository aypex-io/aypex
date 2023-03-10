require "spec_helper"

module Aypex
  describe Aypex::Order do
    let(:order) { create(:order) }

    describe "#tax_zone" do
      let(:bill_address) { create(:address) }
      let(:ship_address) { create(:address) }
      let(:order) { Aypex::Order.create(ship_address: ship_address, bill_address: bill_address) }
      let(:zone) { create(:zone) }

      context "when no zones exist" do
        it "returns nil" do
          expect(order.tax_zone).to be_nil
        end
      end

      context "when tax_using_ship_address: true" do
        before { order.store.tax_using_ship_address = true }

        it "calculates using ship_address" do
          expect(Aypex::Zone).to receive(:match).at_least(:once).with(ship_address)
          expect(Aypex::Zone).not_to receive(:match).with(bill_address)
          order.tax_zone
        end
      end

      context "when tax_using_ship_address: false" do
        before { order.store.tax_using_ship_address = false }

        it "calculates using bill_address" do
          expect(Aypex::Zone).to receive(:match).at_least(:once).with(bill_address)
          expect(Aypex::Zone).not_to receive(:match).with(ship_address)
          order.tax_zone
        end
      end

      context "when there is a default tax zone" do
        before do
          @default_zone = create(:zone, name: "foo_zone")
          allow(Aypex::Zone).to receive_messages default_tax: @default_zone
        end

        context "when there is a matching zone" do
          before { allow(Aypex::Zone).to receive_messages(match: zone) }

          it "returns the matching zone" do
            expect(order.tax_zone).to eq(zone)
          end
        end

        context "when there is no matching zone" do
          before { allow(Aypex::Zone).to receive_messages(match: nil) }

          it "returns the default tax zone" do
            expect(order.tax_zone).to eq(@default_zone)
          end
        end
      end

      context "when no default tax zone" do
        before { allow(Aypex::Zone).to receive_messages default_tax: nil }

        context "when there is a matching zone" do
          before { allow(Aypex::Zone).to receive_messages(match: zone) }

          it "returns the matching zone" do
            expect(order.tax_zone).to eq(zone)
          end
        end

        context "when there is no matching zone" do
          before { allow(Aypex::Zone).to receive_messages(match: nil) }

          it "returns nil" do
            expect(order.tax_zone).to be_nil
          end
        end
      end
    end
  end
end
