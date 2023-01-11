module Aypex
  class StoreMailerLogo < Asset
    if Aypex::Config.public_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :attachment
    end

    VALID_CONTENT_TYPES = ["image/png", "image/jpg", "image/jpeg"].freeze

    validates :attachment, content_type: VALID_CONTENT_TYPES
  end
end
