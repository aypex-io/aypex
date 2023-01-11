module Aypex
  class Digital < Aypex::Base
    belongs_to :variant
    has_many :digital_links, dependent: :destroy

    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end

    if Aypex::Config.private_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.private_storage_service_name
    else
      has_one_attached :attachment
    end

    validates :attachment, attached: true
    validates :variant, presence: true
  end
end
