module Aypex
  module Menus
    class Find < ::Aypex::BaseFinder
      def execute
        return scope.where(location: params[:filter]["location"]) if params[:filter].present? && params[:filter]["location"].present?

        scope
      end
    end
  end
end
