module Aypex
  class PrototypeCategory < Aypex::Base
    belongs_to :category, class_name: "Aypex::Category"
    belongs_to :prototype, class_name: "Aypex::Prototype"

    validates :prototype, :category, presence: true
    validates :prototype_id, uniqueness: {scope: :category_id}
  end
end
