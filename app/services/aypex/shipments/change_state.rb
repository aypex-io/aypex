module Aypex
  module Shipments
    class ChangeState
      prepend Aypex::ServiceModule::Base

      def call(shipment:, state:)
        shipment.send("#{state}!")
        success(shipment.reload)
      rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid, StateMachines::InvalidTransition
        failure(shipment)
      end
    end
  end
end
