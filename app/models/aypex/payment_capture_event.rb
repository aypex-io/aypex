module Aypex
  class PaymentCaptureEvent < Aypex::Base
    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end

    belongs_to :payment, class_name: "Aypex::Payment"

    def display_amount
      Aypex::Money.new(amount, currency: payment.currency)
    end
  end
end
