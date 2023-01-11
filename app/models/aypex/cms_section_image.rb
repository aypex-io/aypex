module Aypex
  class CmsSectionImage < Asset
    if Aypex::Config.public_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :attachment
    end

    IMAGE_COUNT = ["one", "two", "three"]
    IMAGE_TYPES = ["image/png", "image/jpg", "image/jpeg", "image/gif"].freeze
    IMAGE_SIZE = ["sm", "md", "lg", "xl"]

    validates :attachment, attached: true, content_type: IMAGE_TYPES
  end
end
