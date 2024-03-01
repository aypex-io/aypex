module Aypex
  class Image < Aypex::Base
    belongs_to :viewable, polymorphic: true
    belongs_to :asset, class_name: "Aypex::Asset"
  end
end
