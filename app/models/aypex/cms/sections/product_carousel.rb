module Aypex::Cms::Sections
  class ProductCarousel < Aypex::CmsSection
    after_initialize :default_values

    LINKED_RESOURCE_TYPE = ["Aypex::Taxon"]

    private

    def default_values
      self.fit ||= "Screen"
      self.linked_resource_type ||= "Aypex::Taxon"
    end
  end
end
