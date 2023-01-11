module Aypex
  class OptionValueVariant < Aypex::Base
    belongs_to :option_value, class_name: "Aypex::OptionValue"
    belongs_to :variant, touch: true, class_name: "Aypex::Variant"

    validates :option_value, :variant, presence: true
    validates :option_value_id, uniqueness: {scope: :variant_id}
  end
end
