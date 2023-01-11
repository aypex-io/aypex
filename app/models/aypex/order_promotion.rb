module Aypex
  class OrderPromotion < Aypex::Base
    belongs_to :order, class_name: "Aypex::Order"
    belongs_to :promotion, class_name: "Aypex::Promotion"

    delegate :name, :description, :code, :public_metadata, to: :promotion
    delegate :currency, to: :order

    extend Aypex::DisplayMoney
    money_methods :amount

    def amount
      order.all_adjustments.promotion.where(source: promotion.actions).sum(:amount)
    end
  end
end
