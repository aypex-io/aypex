module Aypex
  module Countries
    class Find < ::Aypex::BaseFinder
      def initialize(scope:, params:)
        @scope = scope

        @shippable = String(params[:filter][:shippable]) unless params[:filter].nil?
      end

      def execute
        by_shippability(scope)
      end

      private

      attr_reader :shippable

      def shippable?
        shippable.present?
      end

      def by_shippability(countries)
        return countries unless shippable?

        countries.joins(zones: :shipping_methods).distinct
      end
    end
  end
end
