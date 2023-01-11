module Aypex
  class StorePromotion < Aypex::Base
    self.table_name = "aypex_promotions_stores"

    belongs_to :store, class_name: "Aypex::Store", touch: true
    belongs_to :promotion, class_name: "Aypex::Promotion", touch: true

    validates :store, :promotion, presence: true
    validates :store_id, uniqueness: {scope: :promotion_id}
  end
end
