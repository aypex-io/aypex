module Aypex
  class Price < Aypex::Base
    include VatPriceCalculation
    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end

    acts_as_paranoid

    MAXIMUM_AMOUNT = BigDecimal("99_999_999.99")

    belongs_to :variant, -> { with_deleted }, class_name: "Aypex::Variant", inverse_of: :prices, touch: true

    before_validation :ensure_currency

    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    validates :compare_at_amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    extend DisplayMoney
    money_methods :amount, :price, :compare_at_amount
    alias_method :display_compare_at_price, :display_compare_at_amount

    self.whitelisted_ransackable_attributes = ["amount", "compare_at_amount"]

    def money
      Aypex::Money.new(amount || 0, currency: currency.upcase)
    end

    def amount=(amount)
      self[:amount] = Aypex::LocalizedNumber.parse(amount)
    end

    def compare_at_money
      Aypex::Money.new(compare_at_amount || 0, currency: currency)
    end

    def compare_at_amount=(compare_at_amount)
      self[:compare_at_amount] = Aypex::LocalizedNumber.parse(compare_at_amount)
    end

    alias_attribute :price, :amount
    alias_attribute :compare_at_price, :compare_at_amount

    def price_including_vat_for(price_options)
      options = price_options.merge(tax_category: variant.tax_category)
      gross_amount(price, options)
    end

    def compare_at_price_including_vat_for(price_options)
      options = price_options.merge(tax_category: variant.tax_category)
      gross_amount(compare_at_price, options)
    end

    def display_price_including_vat_for(price_options)
      Aypex::Money.new(price_including_vat_for(price_options), currency: currency)
    end

    def display_compare_at_price_including_vat_for(price_options)
      Aypex::Money.new(compare_at_price_including_vat_for(price_options), currency: currency)
    end

    private

    def ensure_currency
      self.currency ||= Aypex::Store.default.default_currency
    end
  end
end
