module Aypex
  module StockLocations
    module StockItems
      class CreateJob < Aypex::BaseJob
        queue_as :aypex_stock_location_stock_items

        def perform(stock_location)
          Aypex::StockLocations::StockItems::Create.call(stock_location: stock_location)
        end
      end
    end
  end
end
