module Aypex
  class PropertyPrototype < Aypex::Base
    belongs_to :prototype, class_name: "Aypex::Prototype"
    belongs_to :property, class_name: "Aypex::Property"

    validates :prototype, :property, presence: true
    validates :prototype_id, uniqueness: {scope: :property_id}
  end
end
