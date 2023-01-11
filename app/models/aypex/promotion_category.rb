module Aypex
  class PromotionCategory < Aypex::Base
    validates :name, presence: true
    has_many :promotions
  end
end
