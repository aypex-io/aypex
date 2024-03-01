module Aypex
  class Asset::Validate::Image < Aypex::Asset
    validates :attachment, content_type: /\Aimage\/.*\z/
  end
end
