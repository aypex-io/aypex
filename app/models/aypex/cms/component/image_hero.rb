module Aypex::Cms::Component
  class ImageHero < Aypex::CmsComponent
    LINKED_RESOURCE_TYPES = ["Aypex::Category", "Aypex::Product", "Aypex::CmsPage"]

    typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
      s.string :headline, default: "Default Headline", null: false
      s.string :subtitle, default: "", null: false
      s.string :button_text, default: "", null: false
    end
  end
end
