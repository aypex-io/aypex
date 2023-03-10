module Aypex
  module Variants
    class VisibleFinder
      def initialize(scope:, current_currency:)
        @scope = scope
        @current_currency = current_currency
      end

      def execute
        Aypex::Variant.where(id: active_variants).joins(:option_values).order("aypex_option_values.position ASC")
      end

      private

      attr_reader :scope, :current_currency

      def active_variants
        scope.active(current_currency).unscope(:order)
      end
    end
  end
end
