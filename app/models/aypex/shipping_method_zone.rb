module Aypex
  class ShippingMethodZone < Aypex::Base
    belongs_to :shipping_method
    belongs_to :zone
  end
end
