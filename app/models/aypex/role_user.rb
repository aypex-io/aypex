module Aypex
  class RoleUser < Aypex::Base
    belongs_to :role, class_name: "Aypex::Role"
    belongs_to :user, class_name: "::#{Aypex::Config.user_class}"
  end
end
