require "spec_helper"

describe Aypex::CmsComponent do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }
  let(:section) { create(:cms_hero_section) }

  describe "validations" do
    it "validate" do
      expect(described_class.new(cms_section: section, type: "Aypex::Cms::Component::Hero")).to be_valid
    end

    it "validates presence of type" do
      expect(described_class.new(cms_section: section)).not_to be_valid
    end

    it "validates presence of cms_section" do
      expect(described_class.new(type: "Aypex::Cms::Component::Hero")).not_to be_valid
    end
  end

  describe "validate component_count" do
    let(:section_b) { create(:cms_side_by_side_images_section) }

    it "validation passes when section has nil value for count" do
      expect(described_class.new(cms_section: section, type: "Aypex::Cms::Component::Hero")).to be_valid
    end

    it "validation fails when section has nil value for count" do
      expect(described_class.new(cms_section: section_b, type: "Aypex::Cms::Component::SideBySideImages")).not_to be_valid
    end
  end
end
