module Aypex
  class Asset::Validate::ImageSquarePng < Aypex::Asset
    include ImageMethods

    VALID_CONTENT_TYPES = ["image/png"].freeze

    validates :attachment, content_type: VALID_CONTENT_TYPES, aspect_ratio: :square
  end
end
