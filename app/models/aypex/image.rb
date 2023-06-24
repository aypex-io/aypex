module Aypex
  class Image < Asset
    include ImageMethods

    validates :attachment, attached: true, content_type: /\Aimage\/.*\z/
  end
end
