module Aypex::Cms::Component
  class FeaturedArticle < Aypex::CmsComponent
    LINKED_RESOURCE_TYPES = ["Aypex::Category", "Aypex::Product", "Aypex::CmsPage"]

    typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
      s.string :title
      s.string :button_text
    end
  end
end
