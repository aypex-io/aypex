module Aypex
  class PromotionRuleCategory < Aypex::Base
    belongs_to :promotion_rule, class_name: "Aypex::PromotionRule"
    belongs_to :category, class_name: "Aypex::Category"

    validates :promotion_rule, :category, presence: true
    validates :promotion_rule_id, uniqueness: {scope: :category_id}, allow_nil: true
  end
end
