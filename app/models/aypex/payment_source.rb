module Aypex
  class PaymentSource < Aypex::Base
    include Metadata

    belongs_to :payment_method, class_name: "Aypex::PaymentMethod"
    belongs_to :user, class_name: "Aypex::User", optional: true

    validates_uniqueness_of :gateway_payment_profile_id, scope: :type
  end
end
