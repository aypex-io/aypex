module Aypex
  class ProductSummaryPresenter
    include Rails.application.routes.url_helpers

    def initialize(product)
      @product = product
    end

    def call
      {
        name: @product.name,
        images: images
      }
    end

    private

    def images
      @product.images.map do |image|
        {
          url_product: image.generate_url(width: 240)
        }
      end
    end
  end
end
