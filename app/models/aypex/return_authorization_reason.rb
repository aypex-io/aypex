module Aypex
  class ReturnAuthorizationReason < Aypex::Base
    include Aypex::NamedType

    has_many :return_authorizations, dependent: :restrict_with_error
  end
end
