module Aypex
  class ShippingMethodCategory < Aypex::Base
    belongs_to :shipping_method, class_name: "Aypex::ShippingMethod"
    belongs_to :shipping_category, class_name: "Aypex::ShippingCategory", inverse_of: :shipping_method_categories
  end
end
