module Aypex
  module TestingSupport
    module UrlHelpers
      def aypex
        Aypex::Engine.routes.url_helpers
      end
    end
  end
end
