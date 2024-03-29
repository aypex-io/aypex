module Aypex
  class VariantPresenter
    include Rails.application.routes.url_helpers
    include Aypex::BaseHelper
    include Aypex::ProductsHelper

    attr_reader :current_currency, :current_price_options, :current_store

    def initialize(opts = {})
      @variants = opts[:variants]
      @is_product_available_in_currency = opts[:is_product_available_in_currency]
      @current_currency = opts[:current_currency]
      @current_price_options = opts[:current_price_options]
      @current_store = opts[:current_store]
    end

    def call
      @variants.map do |variant|
        {
          display_price: display_price(variant),
          price: variant.price_in(current_currency),
          display_compared_price: display_compared_price(variant),
          should_display_compared_price: should_display_compared_price?(variant),
          is_product_available_in_currency: @is_product_available_in_currency,
          backorderable: backorderable?(variant),
          in_stock: in_stock?(variant),
          option_values: option_values(variant)
        }.merge(
          variant_attributes(variant)
        )
      end
    end

    def option_values(variant)
      variant.option_values.map do |option_value|
        {
          id: option_value.id,
          name: option_value.name,
          presentation: option_value.presentation
        }
      end
    end

    private

    def backorderable?(variant)
      backorderable_variant_ids.include?(variant.id)
    end

    def backorderable_variant_ids
      @backorderable_variant_ids ||= Aypex::Variant.where(id: @variants.map(&:id)).backorderable.ids
    end

    def in_stock?(variant)
      in_stock_variant_ids.include?(variant.id)
    end

    def in_stock_variant_ids
      @in_stock_variant_ids ||= Aypex::Variant.where(id: @variants.map(&:id)).in_stock.ids
    end

    def variant_attributes(variant)
      {
        id: variant.id,
        sku: variant.sku,
        purchasable: variant.purchasable?
      }
    end
  end
end
