module Aypex::Cms::Sections
  class FeaturedArticle < Aypex::CmsSection
    after_initialize :default_values

    store :content, accessors: [:title, :subtitle, :button_text, :rte_content], coder: JSON
    store :settings, accessors: [:gutters], coder: JSON

    LINKED_RESOURCE_TYPE = ["Aypex::Category", "Aypex::Product", "Aypex::CmsPage"]

    def gutters?
      gutters == "Gutters"
    end

    private

    def default_values
      self.gutters ||= "No Gutters"
      self.fit ||= "Screen"
      self.linked_resource_type ||= "Aypex::Category"
    end
  end
end
