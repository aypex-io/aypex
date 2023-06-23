module Aypex
  class Asset::Image::Email < Aypex::Asset
    include ImageMethods

    VALID_CONTENT_TYPES = ["image/png", "image/jpg", "image/jpeg"].freeze

    validates :attachment, content_type: VALID_CONTENT_TYPES
  end
end
