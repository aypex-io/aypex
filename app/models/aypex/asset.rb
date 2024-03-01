module Aypex
  class Asset < Aypex::Base
    include ImageMethods

    include SingleStoreResource
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    belongs_to :store, touch: true

    has_many :images, class_name: "Aypex::Image"

    if Aypex::Config.public_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :attachment
    end

    validates :attachment, attached: true

    default_scope { includes(attachment_attachment: :blob) }
  end
end
