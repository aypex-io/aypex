module Aypex
  class OptionValue < Aypex::Base
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    belongs_to :option_type, class_name: "Aypex::OptionType", touch: true, inverse_of: :option_values

    acts_as_list scope: :option_type
    auto_strip_attributes :name, :presentation

    has_many :option_value_variants, class_name: "Aypex::OptionValueVariant"
    has_many :variants, through: :option_value_variants, class_name: "Aypex::Variant"

    with_options presence: true do
      validates :name, uniqueness: {scope: :option_type_id, case_sensitive: false}
      validates :presentation
    end

    scope :filterable, lambda {
      joins(:option_type)
        .where(OptionType.table_name => {filterable: true})
        .distinct
    }

    scope :for_products, lambda { |products|
      joins(:variants)
        .where(Variant.table_name => {product_id: products.map(&:id)})
    }

    after_touch :touch_all_variants

    delegate :name, :presentation, to: :option_type, prefix: true, allow_nil: true

    self.whitelisted_ransackable_attributes = ["presentation"]

    private

    def touch_all_variants
      variants.update_all(updated_at: Time.current)
    end
  end
end
