module Aypex
  class Prototype < Aypex::Base
    include Metadata
    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end

    has_many :property_prototypes, class_name: "Aypex::PropertyPrototype"
    has_many :properties, through: :property_prototypes, class_name: "Aypex::Property"

    has_many :option_type_prototypes, class_name: "Aypex::OptionTypePrototype"
    has_many :option_types, through: :option_type_prototypes, class_name: "Aypex::OptionType"

    has_many :prototype_categories, class_name: "Aypex::PrototypeCategory"
    has_many :categories, through: :prototype_categories, class_name: "Aypex::Category"

    validates :name, presence: true
  end
end
