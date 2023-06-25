module Aypex
  class Asset::Validate::Image < Aypex::Asset
    include ImageMethods

    validates :attachment, content_type: /\Aimage\/.*\z/
  end
end
