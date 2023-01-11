module Aypex
  class OptionTypePrototype < Aypex::Base
    belongs_to :option_type, class_name: "Aypex::OptionType"
    belongs_to :prototype, class_name: "Aypex::Prototype"

    validates :prototype, :option_type, presence: true
    validates :prototype_id, uniqueness: {scope: :option_type_id}
  end
end
