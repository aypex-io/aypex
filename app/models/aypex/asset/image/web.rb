module Aypex
  class Asset::Image::Web < Aypex::Asset
    include ImageMethods

    validates :attachment, attached: true, content_type: /\Aimage\/.*\z/
  end
end
