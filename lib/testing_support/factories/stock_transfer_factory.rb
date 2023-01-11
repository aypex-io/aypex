FactoryBot.define do
  factory :stock_transfer, class: Aypex::StockTransfer do
    destination_location {}
    number {}
    reference {}
    source_location {}
    type {}
  end
end
