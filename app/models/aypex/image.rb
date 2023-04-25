module Aypex
  class Image < Asset
    include Configuration::ActiveStorage
    include Rails.application.routes.url_helpers
    include ::Aypex::ImageMethods
  end
end
