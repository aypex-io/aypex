module Aypex
  class Asset < Aypex::Base
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    belongs_to :viewable, polymorphic: true, touch: true
    acts_as_list scope: [:viewable_id, :viewable_type]
  end
end
