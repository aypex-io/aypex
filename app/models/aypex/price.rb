module Aypex
  class Price < Aypex::Base
    include VatPriceCalculation
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    acts_as_paranoid

    MAXIMUM_AMOUNT = BigDecimal("99_999_999.99")

    belongs_to :variant, -> { with_deleted }, class_name: "Aypex::Variant", inverse_of: :prices, touch: true

    before_validation :ensure_currency

    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    validates :compared_amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    validates :variant, presence: true
    validates :currency, presence: true, uniqueness: {case_sensitive: false, scope: :variant}

    extend DisplayMoney
    money_methods :amount, :price, :compared_amount

    alias_attribute :price, :amount
    alias_attribute :compared_price, :compared_amount

    alias_method :display_compared_price, :display_compared_amount

    self.whitelisted_ransackable_attributes = ["amount", "currency", "compared_amount"]

    def money
      Aypex::Money.new(amount || 0, currency: currency.upcase)
    end

    def amount=(amount)
      self[:amount] = Aypex::LocalizedNumber.parse(amount)
    end

    def compare_at_money
      Aypex::Money.new(compared_amount || 0, currency: currency)
    end

    def compared_amount=(compared_amount)
      self[:compared_amount] = Aypex::LocalizedNumber.parse(compared_amount)
    end

    def price_including_vat_for(price_options)
      amount_inc_vat(price_options)
    end

    def amount_inc_vat(price_options)
      options = price_options.merge(tax_category: variant.tax_category)
      gross_amount(price, options)
    end

    def compared_price_including_vat_for(price_options)
      compared_amount_inc_vat(price_options)
    end

    def compared_amount_inc_vat(price_options)
      options = price_options.merge(tax_category: variant.tax_category)
      gross_amount(compared_price, options)
    end

    def display_price_including_vat_for(price_options)
      display_amount_inc_vat(price_options)
    end

    def display_amount_inc_vat(price_options)
      Aypex::Money.new(amount_inc_vat(price_options), currency: currency)
    end

    def display_compared_price_including_vat_for(price_options)
      display_compared_amount_inc_vat(price_options)
    end

    def display_compared_amount_inc_vat(price_options)
      Aypex::Money.new(compared_amount_inc_vat(price_options), currency: currency)
    end

    private

    def ensure_currency
      self.currency ||= Aypex::Store.default.default_currency
    end
  end
end
