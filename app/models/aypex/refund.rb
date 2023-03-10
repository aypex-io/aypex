module Aypex
  class Refund < Aypex::Base
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)
    include Aypex::Security::Refunds if defined?(Aypex::Security::Refunds)

    with_options inverse_of: :refunds do
      belongs_to :payment
      belongs_to :reimbursement, optional: true
    end
    belongs_to :reason, class_name: "Aypex::RefundReason", foreign_key: :refund_reason_id

    has_many :log_entries, as: :source

    with_options presence: true do
      validates :payment, :reason
      # can't require this on create because the perform! in after_create needs to run first
      validates :transaction_id, on: :update
      validates :amount, numericality: {greater_than: 0, allow_nil: true}
    end
    validate :amount_is_less_than_or_equal_to_allowed_amount, on: :create, if: :amount

    after_create :perform!
    after_create :create_log_entry

    scope :non_reimbursement, -> { where(reimbursement_id: nil) }

    attr_reader :response

    def money
      Aypex::Money.new(amount, currency: payment.currency)
    end
    alias_method :display_amount, :money

    class << self
      def total_amount_reimbursed_for(reimbursement)
        reimbursement.refunds.to_a.sum(&:amount)
      end
    end

    def description
      payment.payment_method.name
    end

    private

    # attempts to perform the refund.
    # raises an error if the refund fails.
    def perform!
      return true if transaction_id.present?

      credit_cents = Aypex::Money.new(amount.to_f, currency: payment.currency).amount_in_cents

      @response = process!(credit_cents)

      self.transaction_id = @response.authorization
      update_columns(transaction_id: transaction_id)
      update_order
    end

    # return an activemerchant response object if successful or else raise an error
    def process!(credit_cents)
      response = if payment.payment_method.payment_profiles_supported?
        payment.payment_method.credit(credit_cents, payment.source, payment.transaction_id, originator: self)
      else
        payment.payment_method.credit(credit_cents, payment.transaction_id, originator: self)
      end

      unless response.success?
        Rails.logger.error(I18n.t(:gateway_error, scope: :aypex) + "  #{response.to_yaml}")
        text = response.params["message"] || response.params["response_reason_text"] || response.message
        raise GatewayError, text
      end

      response
    rescue ActiveMerchant::ConnectionError => e
      Rails.logger.error(I18n.t(:gateway_error, scope: :aypex) + "  #{e.inspect}")
      raise GatewayError, I18n.t(:unable_to_connect_to_gateway, scope: :aypex)
    end

    def create_log_entry
      log_entries.create!(details: @response.to_yaml)
    end

    def amount_is_less_than_or_equal_to_allowed_amount
      if amount > payment.credit_allowed
        errors.add(:amount, :greater_than_allowed)
      end
    end

    def update_order
      payment.order.updater.update
    end
  end
end
