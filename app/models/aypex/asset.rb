module Aypex
  class Asset < Aypex::Base
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    if Aypex::Config.public_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :attachment
    end

    validates :attachment, attached: true

    default_scope { includes(attachment_attachment: :blob) }

    belongs_to :viewable, polymorphic: true, touch: true
    acts_as_list scope: [:viewable_id, :viewable_type]
  end
end
