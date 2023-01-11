module Aypex
  module Account
    class Create
      prepend Aypex::ServiceModule::Base

      def call(user_params: {})
        user = Aypex::Config.user_class.new(user_params)

        if user.save
          success(user)
        else
          failure(user)
        end
      end
    end
  end
end
