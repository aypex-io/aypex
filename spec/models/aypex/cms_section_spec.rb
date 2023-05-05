require "spec_helper"

describe Aypex::CmsSection do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }
  let(:section) { create(:cms_hero_section) }

  describe "validations" do
    it "Valid Example" do
      expect(described_class.new(name: "Got Name", type: "Aypex::Cms::Section::Hero", cms_page: homepage)).to be_valid
    end

    it "validates presence of name" do
      expect(described_class.new(type: "Aypex::Cms::Section::Hero", cms_page: homepage)).not_to be_valid
    end

    it "validates presence of type" do
      expect(described_class.new(name: "Got Name", cms_page: homepage)).not_to be_valid
    end

    it "validates presence of cms_page" do
      expect(described_class.new(name: "Got Name", type: "Aypex::Cms::Section::Hero")).not_to be_valid
    end
  end

  describe "#ensure_components" do
    let(:section_b) { build(:cms_side_by_side_images_section) }

    before {
      section_b.save
      section_b.reload
    }

    it "sets the component type" do
      expect(section_b.cms_components.first.type).to match("Aypex::Cms::Component::SideBySideImages")
    end

    it "sets the cms_section_id" do
      expect(section_b.cms_components.first.cms_section_id).to eq(section_b.id)
    end

    it "sets the linked_resource_type" do
      expect(section_b.cms_components.first.linked_resource_type).to match("Aypex::Category")
    end
  end
end
