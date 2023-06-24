module Aypex
  class Asset::Image::Favicon < Aypex::Asset
    include ImageMethods

    VALID_CONTENT_TYPES = ["image/png", "image/x-icon", "image/vnd.microsoft.icon"].freeze

    validates :attachment,
      content_type: VALID_CONTENT_TYPES,
      aspect_ratio: :square,
      size: {less_than_or_equal_to: 1.megabyte}
  end
end
