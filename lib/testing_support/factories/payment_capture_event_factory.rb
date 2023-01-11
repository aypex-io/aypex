FactoryBot.define do
  factory :payment_capture_event, class: Aypex::PaymentCaptureEvent do
    payment
    amount { 10.0 }
  end
end
