require "spec_helper"

module Aypex
  describe StockLocations::StockItems::CreateJob, :job do
    let!(:stock_location) { create(:stock_location) }

    it "enqueues the creation of the stock location stock items" do
      expect { described_class.perform_later(stock_location) }.to(
        have_enqueued_job.on_queue("aypex_stock_location_stock_items")
      )
    end
  end
end
