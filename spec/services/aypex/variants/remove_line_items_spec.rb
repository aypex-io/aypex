require "spec_helper"

module Aypex
  describe Variants::RemoveLineItems do
    subject { described_class }

    describe "#call" do
      let(:variant) { create(:variant) }
      let(:orders) { create_list(:order_with_line_items, 3) }

      before do
        orders.each { |order| order.line_items.take.update(variant: variant) }
      end

      it "schedules a Aypex::LineItems::RemoveFromOrderJob for each order" do
        expect(Aypex::Variants::RemoveLineItemJob).to receive(:perform_later).with(line_item: orders.first.line_items.take).once
        expect(Aypex::Variants::RemoveLineItemJob).to receive(:perform_later).with(line_item: orders.second.line_items.take).once
        expect(Aypex::Variants::RemoveLineItemJob).to receive(:perform_later).with(line_item: orders.third.line_items.take).once

        subject.call(variant: variant)
      end
    end
  end
end
