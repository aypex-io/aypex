module Aypex
  module Variants
    class OptionTypesFinder
      COLOR_TYPE = "color".freeze

      def initialize(variant_ids:)
        @variant_ids = variant_ids
      end

      def execute
        Aypex::OptionType.includes(option_values: :variants).where(aypex_variants: {id: variant_ids})
          .reorder("aypex_option_types.position ASC, aypex_option_values.position ASC")
          .partition { |option_type| option_type.name.downcase == COLOR_TYPE }.flatten
      end

      private

      attr_reader :variant_ids
    end
  end
end
