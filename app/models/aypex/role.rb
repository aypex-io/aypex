module Aypex
  class Role < Aypex::Base
    include UniqueName

    has_many :role_users, class_name: "Aypex::RoleUser", dependent: :destroy
    has_many :users, through: :role_users, class_name: "::#{Aypex::Config.user_class}"
  end
end
