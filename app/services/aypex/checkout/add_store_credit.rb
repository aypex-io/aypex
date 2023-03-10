module Aypex
  module Checkout
    class AddStoreCredit
      prepend Aypex::ServiceModule::Base

      def call(order:, amount: nil)
        @order = order
        return failed unless @order

        remaining_total = amount ? [amount, @order.outstanding_balance].min : @order.outstanding_balance

        return failure(nil, I18n.t(:error_user_does_not_have_any_store_credits, scope: :aypex)) unless @order.user&.store_credits&.any?

        ApplicationRecord.transaction do
          @order.payments.store_credits.where(state: :checkout).map(&:invalidate!)

          apply_store_credits(remaining_total)
        end

        @order.reload.payments.store_credits.valid.any? ? success(@order) : failure(@order)
      end

      private

      def apply_store_credits(remaining_total)
        payment_method = Aypex::PaymentMethod::StoreCredit.available.first
        raise "Store credit payment method could not be found" unless payment_method

        @order.user.store_credits.for_store(@order.store).order_by_priority.each do |credit|
          break if remaining_total.zero?
          next if credit.amount_remaining.zero?

          amount_to_take = store_credit_amount(credit, remaining_total)
          create_store_credit_payment(payment_method, credit, amount_to_take)
          remaining_total -= amount_to_take
        end
      end

      def create_store_credit_payment(payment_method, credit, amount)
        @order.payments.create!(
          source: credit,
          payment_method: payment_method,
          amount: amount,
          state: "checkout",
          response_code: credit.generate_authorization_code
        )
      end

      def store_credit_amount(credit, total)
        [credit.amount_remaining, total].min
      end
    end
  end
end
