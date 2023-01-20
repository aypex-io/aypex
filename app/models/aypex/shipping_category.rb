module Aypex
  class ShippingCategory < Aypex::Base
    include UniqueName
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    with_options inverse_of: :shipping_category do
      has_many :products
      has_many :shipping_method_categories
    end
    has_many :shipping_methods, through: :shipping_method_categories
  end
end
