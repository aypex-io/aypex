require "spec_helper"

describe Aypex::CmsSection do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }
  let(:section) { create(:cms_hero_image_section) }

  describe "validations" do
    it "Valid Example" do
      expect(described_class.new(name: "Got Name", type: "Aypex::Cms::Section::HeroImage", cms_page: homepage)).to be_valid
    end

    it "validates presence of name" do
      expect(described_class.new(type: "Aypex::Cms::Section::HeroImage", cms_page: homepage)).not_to be_valid
    end

    it "validates presence of type" do
      expect(described_class.new(name: "Got Name", cms_page: homepage)).not_to be_valid
    end

    it "validates presence of cms_page" do
      expect(described_class.new(name: "Got Name", type: "Aypex::Cms::Section::HeroImage")).not_to be_valid
    end
  end

  describe "#sections_for_select" do
    it "returns a valid array of sections formatted for select" do
      expect(section.sections_for_select).to contain_exactly(["Hero Image", "Aypex::Cms::Section::HeroImage"], ["Featured Article", "Aypex::Cms::Section::FeaturedArticle"], ["Product Carousel", "Aypex::Cms::Section::ProductCarousel"], ["Image Gallery", "Aypex::Cms::Section::ImageGallery"], ["Side By Side Images", "Aypex::Cms::Section::SideBySideImages"], ["Rich Text Content", "Aypex::Cms::Section::RichTextContent"])
    end
  end

  describe "#ensure_components" do
    let(:section_b) { build(:cms_hero_image_section) }

    before {
      section_b.save
      section_b.reload
    }

    it "sets the component type" do
      expect(section_b.cms_components.first.type).to match("Aypex::Cms::Component::HeroImage")
    end

    it "sets the cms_section_id" do
      expect(section_b.cms_components.first.cms_section_id).to eq(section_b.id)
    end

    it "sets the linked_resource_type" do
      expect(section_b.cms_components.first.linked_resource_type).to match("Aypex::Category")
    end
  end
end
