module Aypex
  class Asset::Validate::ImageSquare < Aypex::Asset
    include ImageMethods

    validates :attachment, attached: true, content_type: /\Aimage\/.*\z/, aspect_ratio: :square
  end
end
