module Aypex::Cms::Section
  class RichText < Aypex::CmsSection
    typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
      s.boolean :is_full_screen, default: false, null: false
      s.boolean :has_gutters, default: true, null: false
    end
  end
end
