# Base class for all promotion rules
module Aypex
  class PromotionRule < Aypex::Base
    belongs_to :promotion, class_name: "Aypex::Promotion", inverse_of: :promotion_rules

    delegate :stores, to: :promotion

    scope :of_type, ->(t) { where(type: t) }

    validate :unique_per_promotion, on: :create

    def self.for(promotable)
      all.select { |rule| rule.applicable?(promotable) }
    end

    def applicable?(_promotable)
      raise "applicable? should be implemented in a sub-class of Aypex::PromotionRule"
    end

    def eligible?(_promotable, _options = {})
      raise "eligible? should be implemented in a sub-class of Aypex::PromotionRule"
    end

    # This states if a promotion can be applied to the specified line item
    # It is true by default, but can be overridden by promotion rules to provide conditions
    def actionable?(_line_item)
      true
    end

    def eligibility_errors
      @eligibility_errors ||= ActiveModel::Errors.new(self)
    end

    private

    def unique_per_promotion
      if Aypex::PromotionRule.exists?(promotion_id: promotion_id, type: self.class.name)
        errors.add(:base, "Promotion already contains this rule type")
      end
    end

    def eligibility_error_message(key, options = {})
      I18n.t("aypex.eligibility_errors.messages.#{key}", **options)
    end
  end
end
