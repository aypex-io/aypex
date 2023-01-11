# Default implementation of User.  This class is intended to be modified by extensions (ex. aypex_auth_devise)
module Aypex
  class LegacyUser < Aypex::Base
    include UserAddress
    include UserPaymentSource
    include UserMethods
    include Aypex::Metadata

    self.table_name = "aypex_users"

    attr_accessor :password, :password_confirmation
  end
end
