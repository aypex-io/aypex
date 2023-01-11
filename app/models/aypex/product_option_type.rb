module Aypex
  class ProductOptionType < Aypex::Base
    with_options inverse_of: :product_option_types do
      belongs_to :product, class_name: "Aypex::Product"
      belongs_to :option_type, class_name: "Aypex::OptionType"
    end
    acts_as_list scope: :product

    validates :product, :option_type, presence: true
    validates :product_id, uniqueness: {scope: :option_type_id}, allow_nil: true
  end
end
