require_dependency "aypex/payment/processing"

module Aypex
  class Payment < Aypex::Base
    include Aypex::NumberGenerator.new(prefix: "P", letters: true, length: 7)
    include NumberIdentifier
    include NumberAsParam
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)
    include Aypex::Security::Payments if defined?(Aypex::Security::Payments)
    include Aypex::Payment::Processing

    NON_RISKY_AVS_CODES = ["B", "D", "H", "J", "M", "Q", "T", "V", "X", "Y"].freeze
    RISKY_AVS_CODES = ["A", "C", "E", "F", "G", "I", "K", "L", "N", "O", "P", "R", "S", "U", "W", "Z"].freeze
    INVALID_STATES = %w[failed invalid void].freeze

    with_options inverse_of: :payments do
      belongs_to :order, class_name: "Aypex::Order", touch: true
      belongs_to :payment_method, -> { with_deleted }, class_name: "Aypex::PaymentMethod"
    end
    belongs_to :source, polymorphic: true

    has_many :offsets, -> { offset_payment }, class_name: "Aypex::Payment", foreign_key: :source_id
    has_many :log_entries, as: :source
    has_many :state_changes, as: :stateful
    has_many :capture_events, class_name: "Aypex::PaymentCaptureEvent"
    has_many :refunds, inverse_of: :payment

    validates :payment_method, presence: true
    validates :source, presence: true, if: -> { payment_method&.source_required? }
    validate :payment_method_available_for_order, on: :create

    before_validation :validate_source

    after_save :create_payment_profile, if: :profiles_supported?

    # update the order totals, etc.
    set_callback :save, :after, :update_order, unless: -> { capture_on_dispatch }

    # invalidate previously entered payments
    after_create :invalidate_old_payments
    after_create :create_eligible_credit_event

    attr_accessor :source_attributes, :request_env, :capture_on_dispatch

    after_initialize :build_source

    validates :amount, numericality: true

    delegate :store_credit?, to: :payment_method, allow_nil: true
    delegate :name, to: :payment_method, allow_nil: true, prefix: true
    default_scope { order(:created_at) }

    scope :from_credit_card, -> { where(source_type: "Aypex::CreditCard") }
    scope :with_state, ->(s) { where(state: s.to_s) }
    # "offset" is reserved by activerecord
    scope :offset_payment, -> { where("source_type = 'Aypex::Payment' AND amount < 0 AND state = 'completed'") }

    scope :checkout, -> { with_state("checkout") }
    scope :completed, -> { with_state("completed") }
    scope :pending, -> { with_state("pending") }
    scope :processing, -> { with_state("processing") }
    scope :failed, -> { with_state("failed") }

    scope :risky, -> { where("avs_response IN (?) OR (cvv_response_code IS NOT NULL and cvv_response_code != 'M') OR state = 'failed'", RISKY_AVS_CODES) }
    scope :valid, -> { where.not(state: INVALID_STATES) }

    scope :store_credits, -> { where(source_type: Aypex::StoreCredit.to_s) }
    scope :not_store_credits, -> { where(arel_table[:source_type].not_eq(Aypex::StoreCredit.to_s).or(arel_table[:source_type].eq(nil))) }

    self.whitelisted_ransackable_associations = %w[payment_method order source]
    self.whitelisted_ransackable_attributes = %w[number amount state response_code avs_response cvv_response_code cvv_response_message]

    # transaction_id is much easier to understand
    def transaction_id
      response_code
    end

    delegate :currency, to: :order

    # order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine initial: :checkout do
      # With card payments, happens before purchase or authorization happens
      #
      # Setting it after creating a profile and authorizing a full amount will
      # prevent the payment from being authorized again once Order transitions
      # to complete
      event :started_processing do
        transition from: [:checkout, :pending, :completed, :processing], to: :processing
      end
      # When processing during checkout fails
      event :failure do
        transition from: [:pending, :processing], to: :failed
      end
      # With card payments this represents authorizing the payment
      event :pend do
        transition from: [:checkout, :processing], to: :pending
      end
      # With card payments this represents completing a purchase or capture transaction
      event :complete do
        transition from: [:processing, :pending, :checkout], to: :completed
      end
      after_transition to: :completed, do: :after_completed
      event :void do
        transition from: [:pending, :processing, :completed, :checkout], to: :void
      end
      after_transition to: :void, do: :after_void
      # when the card brand isn't supported
      event :invalidate do
        transition from: [:checkout], to: :invalid
      end

      after_transition do |payment, transition|
        payment.state_changes.create!(
          previous_state: transition.from,
          next_state: transition.to,
          name: "payment"
        )
      end
    end

    def source
      return super if payment_method.nil?
      return super unless payment_method.source_required?

      payment_method.payment_source_class.unscoped { super }
    end

    def money
      Aypex::Money.new(amount, currency: currency)
    end
    alias_method :display_amount, :money

    def amount=(amount)
      self[:amount] =
        case amount
        when String
          separator = I18n.t("number.currency.format.separator")
          number = amount.delete("^0-9-#{separator}.").tr(separator, ".")
          number.to_d if number.present?
        end || amount
    end

    def offsets_total
      offsets.sum(:amount)
    end

    def credit_allowed
      amount - (offsets_total.abs + refunds.sum(:amount))
    end

    def can_credit?
      credit_allowed > 0
    end

    # see https://github.com/aypex/aypex/issues/981
    def build_source
      return unless new_record?

      if source_attributes.present? && source.blank? && payment_method.try(:payment_source_class)
        self.source = payment_method.payment_source_class.new(source_attributes)
        source.payment_method_id = payment_method.id
        source.user_id = order.user_id if order
      end
    end

    def actions
      return [] unless payment_source&.respond_to?(:actions)

      payment_source.actions.select { |action| !payment_source.respond_to?(:"can_#{action}?") || payment_source.send(:"can_#{action}?", self) }
    end

    def payment_source
      res = source.is_a?(Payment) ? source.source : source
      res || payment_method
    end

    def is_avs_risky?
      return false if avs_response.blank? || NON_RISKY_AVS_CODES.include?(avs_response)

      true
    end

    def is_cvv_risky?
      return false if cvv_response_code == "M"
      return false if cvv_response_code.nil?
      return false if cvv_response_message.present?

      true
    end

    def captured_amount
      capture_events.sum(:amount)
    end

    def uncaptured_amount
      amount - captured_amount
    end

    def editable?
      checkout? || pending?
    end

    private

    def after_void
      # this method is prepended in api/ to queue Webhooks requests
    end

    def after_completed
      # this method is prepended in api/ to queue Webhooks requests
    end

    def has_invalid_state?
      INVALID_STATES.include?(state)
    end

    def validate_source
      if source && !source.valid?
        source.errors.map { |error| {field: error.attribute, message: error&.message} }.each do |err|
          next if err[:field].blank? || err[:message].blank?

          add_source_error(err[:field], err[:message])
        end
      end
      !errors.present?
    end

    def payment_method_available_for_order
      return if payment_method.blank?
      return if order.blank?

      errors.add(:payment_method, :invalid) if !payment_method.available_for_order?(order) || !payment_method.available_for_store?(order.store)
    end

    def add_source_error(field, message)
      # i18n-tasks-use I18n.t('aypex.credit_card')
      field_name = I18n.t("activerecord.attributes.#{source.class.to_s.underscore}.#{field}")
      errors.add(I18n.t(source.class.to_s.demodulize.underscore, scope: :aypex), "#{field_name} #{message}")
    end

    def profiles_supported?
      payment_method.respond_to?(:payment_profiles_supported?) && payment_method.payment_profiles_supported?
    end

    def create_payment_profile
      # Don't attempt to create on bad payments.
      return if has_invalid_state?
      # Payment profile cannot be created without source
      return unless source
      # Imported payments shouldn't create a payment profile.
      return if source.imported

      payment_method.create_profile(self)
    rescue ActiveMerchant::ConnectionError => e
      gateway_error e
    end

    def split_uncaptured_amount
      if uncaptured_amount > 0
        order.payments.create!(
          amount: uncaptured_amount,
          payment_method: payment_method,
          source: source,
          state: "pending",
          capture_on_dispatch: true
        ).authorize!
        update(amount: captured_amount)
      end
    end

    def update_order
      order.updater.update_payment_total if completed? || void?

      if order.completed?
        order.updater.update_payment_state
        order.updater.update_shipments
        order.updater.update_shipment_state
      end

      order.persist_totals if completed? || order.completed?
    end

    def create_eligible_credit_event
      # When cancelling an order, a payment with the negative amount
      # of the payment total is created to refund the customer. That
      # payment has a source of itself (Aypex::Payment) no matter the
      # type of payment getting refunded, hence the additional check
      # if the source is a store credit.
      return unless store_credit? && source.is_a?(Aypex::StoreCredit)

      # creates the store credit event
      source.update!(action: Aypex::StoreCredit::ELIGIBLE_ACTION,
        action_amount: amount,
        action_authorization_code: response_code)
    end

    def invalidate_old_payments
      # invalid payment or store_credit payment shouldn't invalidate other payment types
      return if has_invalid_state? || store_credit?

      order.payments.with_state("checkout").where.not(id: id).each do |payment|
        payment.invalidate! unless payment.store_credit?
      end
    end
  end
end
