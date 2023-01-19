module Aypex
  class Digital < Aypex::Base
    belongs_to :variant
    has_many :digital_links, dependent: :destroy

    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    if Aypex::Config.private_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.private_storage_service_name
    else
      has_one_attached :attachment
    end

    validates :attachment, attached: true
    validates :variant, presence: true
  end
end
