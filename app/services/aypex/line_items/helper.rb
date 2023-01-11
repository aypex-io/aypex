module Aypex
  module LineItems
    module Helper
      protected

      def recalculate_service
        Aypex::Dependencies.cart_recalculate_service.constantize
      end
    end
  end
end
