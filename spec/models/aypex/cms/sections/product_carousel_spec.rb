require "spec_helper"

describe Aypex::Cms::Sections::ProductCarousel do
  let!(:store) { create(:store) }
  let!(:homepage) { create(:cms_homepage, store: store) }

  it "validates presence of name" do
    expect(described_class.new(name: nil, cms_page: homepage)).not_to be_valid
  end

  it "validates presence of page" do
    expect(described_class.new(name: "Got Name")).not_to be_valid
  end

  context "when a new Product Carousel section is created" do
    let!(:product_carousel_section) { create(:cms_product_carousel_section, cms_page: homepage) }

    it "sets fit to Screen" do
      section = Aypex::CmsSection.find(product_carousel_section.id)

      expect(section.fit).to eq("Screen")
    end

    it "sets linked_resource_type to Aypex::Category" do
      section = Aypex::CmsSection.find(product_carousel_section.id)

      expect(section.linked_resource_type).to eq("Aypex::Category")
    end
  end
end
