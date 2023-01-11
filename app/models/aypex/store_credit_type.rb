module Aypex
  class StoreCreditType < Aypex::Base
    DEFAULT_TYPE_NAME = "Expiring".freeze
    has_many :store_credits, class_name: "Aypex::StoreCredit", foreign_key: "type_id"

    validates :name, presence: true
  end
end
