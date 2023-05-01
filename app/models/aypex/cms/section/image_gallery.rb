module Aypex::Cms::Section
  class ImageGallery < Aypex::CmsSection
    typed_store(:settings, coder: ActiveRecord::TypedStore::IdentityCoder) do |s|
      s.string :fit, default: "Fit to Container", null: false
      s.string :gutters, default: "With Gutters", null: false
    end
  end
end
