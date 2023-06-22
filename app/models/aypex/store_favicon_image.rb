module Aypex
  class StoreFaviconImage < Asset
    if Aypex::Config.public_storage_service_name
      has_one_attached :favicon_attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :favicon_attachment
    end

    VALID_CONTENT_TYPES = ["image/png", "image/x-icon", "image/vnd.microsoft.icon"].freeze

    validates :f_attachment,
      content_type: VALID_CONTENT_TYPES,
      dimension: {min: 56..56, max: 500..500},
      aspect_ratio: :square,
      size: {less_than_or_equal_to: 1.megabyte}
  end
end
