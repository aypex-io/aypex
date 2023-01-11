module Aypex
  module Variants
    class RemoveFromIncompleteOrdersJob < Aypex::BaseJob
      def perform(variant)
        Aypex::Variants::RemoveLineItems.call(variant: variant)
      end
    end
  end
end
