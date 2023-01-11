module Aypex
  module TestingSupport
    module ControllerRequests
      extend ActiveSupport::Concern
      included do
        routes { Aypex::Engine.routes }
      end
    end
  end
end
