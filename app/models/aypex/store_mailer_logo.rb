module Aypex
  class StoreMailerLogo < Asset
    if Aypex::Config.public_storage_service_name
      has_one_attached :mailer_attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :mailer_attachment
    end

    VALID_CONTENT_TYPES = ["image/png", "image/jpg", "image/jpeg"].freeze

    validates :mailer_attachment, content_type: VALID_CONTENT_TYPES
  end
end
