module Aypex
  module Seeds
    class Roles
      prepend Aypex::ServiceModule::Base

      def call
        Aypex::Role.where(name: "admin").first_or_create!
      end
    end
  end
end
