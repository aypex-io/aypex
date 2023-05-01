module Aypex::Cms::Section
  class RichTextContent < Aypex::CmsSection
    after_initialize :default_values

    store :content, accessors: [:rte_content], coder: JSON

    private

    def default_values
      self.fit ||= "Container"
    end
  end
end
