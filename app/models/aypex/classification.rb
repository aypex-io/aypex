module Aypex
  class Classification < Aypex::Base
    self.table_name = "aypex_products_categories"
    acts_as_list scope: :category

    with_options inverse_of: :classifications, touch: true do
      belongs_to :product, class_name: "Aypex::Product"
      belongs_to :category, class_name: "Aypex::Category"
    end

    validates :category, :product, presence: true
    validates :position, numericality: {only_integer: true, allow_blank: true, allow_nil: true}
    # For #3494
    validates :category_id, uniqueness: {scope: :product_id, message: :already_linked, allow_blank: true}

    self.whitelisted_ransackable_attributes = ["category_id", "product_id"]
  end
end
