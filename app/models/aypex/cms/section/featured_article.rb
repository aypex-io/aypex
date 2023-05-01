module Aypex::Cms::Section
  class FeaturedArticle < Aypex::CmsSection
    typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
      s.boolean :is_full_screen, default: true, null: false
      s.boolean :has_gutters, default: true, null: false
    end
  end
end
