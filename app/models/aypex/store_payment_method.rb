module Aypex
  class StorePaymentMethod < Aypex::Base
    self.table_name = "aypex_payment_methods_stores"

    belongs_to :store, class_name: "Aypex::Store", touch: true
    belongs_to :payment_method, class_name: "Aypex::PaymentMethod", touch: true

    validates :store, :payment_method, presence: true
    validates :store_id, uniqueness: {scope: :payment_method_id}
  end
end
