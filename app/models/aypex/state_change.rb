module Aypex
  class StateChange < Aypex::Base
    belongs_to :user, class_name: "::#{Aypex::Config.user_class}", optional: true
    belongs_to :stateful, polymorphic: true

    def <=>(other)
      created_at <=> other.created_at
    end
  end
end
