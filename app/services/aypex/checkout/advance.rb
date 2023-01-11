module Aypex
  module Checkout
    class Advance
      prepend Aypex::ServiceModule::Base

      def call(order:)
        Aypex::Dependencies.checkout_next_service.constantize.call(order: order) until cannot_make_transition?(order)
        success(order)
      end

      private

      def cannot_make_transition?(order)
        order.confirm? || order.complete? || order.errors.present?
      end
    end
  end
end
