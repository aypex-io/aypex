module Aypex
  class PromotionRuleUser < Aypex::Base
    belongs_to :promotion_rule, class_name: "Aypex::PromotionRule"
    belongs_to :user, class_name: "::#{Aypex::Config.user_class}"

    validates :user, :promotion_rule, presence: true
    validates :user_id, uniqueness: {scope: :promotion_rule_id}, allow_nil: true
  end
end
