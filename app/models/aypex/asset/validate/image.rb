module Aypex
  class Asset::Validate::Image < Aypex::Asset
    include ImageMethods

    validates :attachment, attached: true, content_type: /\Aimage\/.*\z/
  end
end
