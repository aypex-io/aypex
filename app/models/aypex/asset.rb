module Aypex
  class Asset < Aypex::Base
    include Support::ActiveStorage
    include Metadata
    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end

    belongs_to :viewable, polymorphic: true, touch: true
    acts_as_list scope: [:viewable_id, :viewable_type]
  end
end
