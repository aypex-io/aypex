module Aypex::Cms::Component
  class RichTextContent < Aypex::CmsComponent
    typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
      s.string :title
      s.string :subtitle
      s.string :button_text
    end
  end
end
