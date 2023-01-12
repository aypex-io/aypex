module Aypex
  module DisplayLink
    extend ActiveSupport::Concern

    included do
      belongs_to :linked_resource, polymorphic: true

      def link
        case linked_resource_type
        when "Aypex::Category"
          return if linked_resource&.permalink.blank?

          "/#{Aypex::Config.storefront_categories_path}/#{linked_resource.permalink}"
        when "Aypex::Product"
          return if linked_resource&.slug.blank?

          "/#{Aypex::Config.storefront_products_path}/#{linked_resource.slug}"
        when "Aypex::CmsPage"
          return if linked_resource&.slug.blank?

          "/#{Aypex::Config.storefront_pages_path}/#{linked_resource.slug}"
        when "Aypex::Linkable::Homepage"
          "/"
        when "Aypex::Linkable::Uri"
          destination
        end
      end
    end
  end
end
