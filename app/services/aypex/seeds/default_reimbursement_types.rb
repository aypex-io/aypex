module Aypex
  module Seeds
    class DefaultReimbursementTypes
      prepend Aypex::ServiceModule::Base

      def call
        # FIXME: we should use translations here
        Aypex::RefundReason.find_or_create_by!(name: "Return processing", mutable: false)
      end
    end
  end
end
