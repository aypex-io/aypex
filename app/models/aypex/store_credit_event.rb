module Aypex
  class StoreCreditEvent < Aypex::Base
    acts_as_paranoid

    belongs_to :store_credit
    belongs_to :originator, polymorphic: true

    scope :exposed_events, -> { where.not(action: [Aypex::StoreCredit::ELIGIBLE_ACTION, Aypex::StoreCredit::AUTHORIZE_ACTION]) }
    scope :reverse_chronological, -> { order(created_at: :desc) }

    delegate :currency, :store, to: :store_credit

    extend DisplayMoney
    money_methods :amount, :user_total_amount

    def display_action
      case action
      when Aypex::StoreCredit::CAPTURE_ACTION
        I18n.t("aypex.store_credit.captured")
      when Aypex::StoreCredit::AUTHORIZE_ACTION
        I18n.t("aypex.store_credit.authorized")
      when Aypex::StoreCredit::ALLOCATION_ACTION
        I18n.t("aypex.store_credit.allocated")
      when Aypex::StoreCredit::VOID_ACTION, Aypex::StoreCredit::CREDIT_ACTION
        I18n.t("aypex.store_credit.credit")
      end
    end

    def order
      store.payments.find_by(response_code: authorization_code).try(:order)
    end
  end
end
