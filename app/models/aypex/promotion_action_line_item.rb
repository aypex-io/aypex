module Aypex
  class PromotionActionLineItem < Aypex::Base
    belongs_to :promotion_action, class_name: "Aypex::Promotion::Actions::CreateLineItems"
    belongs_to :variant, class_name: "Aypex::Variant"

    validates :promotion_action, :variant, :quantity, presence: true
    validates :quantity, numericality: {only_integer: true, message: I18n.t("aypex.validation.must_be_int")}
  end
end
