module Aypex
  module LineItems
    module Helper
      protected

      def recalculate_service
        Aypex::Dependency.cart_recalculate_service.constantize
      end
    end
  end
end
