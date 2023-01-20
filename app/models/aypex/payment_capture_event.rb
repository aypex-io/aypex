module Aypex
  class PaymentCaptureEvent < Aypex::Base
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    belongs_to :payment, class_name: "Aypex::Payment"

    def display_amount
      Aypex::Money.new(amount, currency: payment.currency)
    end
  end
end
