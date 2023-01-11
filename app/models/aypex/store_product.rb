module Aypex
  class StoreProduct < Aypex::Base
    self.table_name = "aypex_products_stores"

    belongs_to :store, class_name: "Aypex::Store", touch: true
    belongs_to :product, class_name: "Aypex::Product", touch: true

    validates :store, :product, presence: true
    validates :store_id, uniqueness: {scope: :product_id}
  end
end
