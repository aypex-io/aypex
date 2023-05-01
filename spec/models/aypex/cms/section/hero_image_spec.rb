require "spec_helper"

describe Aypex::Cms::Section::HeroImage do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }

  context "when a new Hero Image section is created" do
    let(:target_section) { create(:cms_hero_image_section, cms_page: homepage) }

    it "sets gutters to 'Without Gutters'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.gutters).to eq("Without Gutters")
    end

    it "sets fit to 'Fit to Container'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.fit).to eq("Fit to Container")
    end

    it "creates cms_component with 'Aypex::Cms::Component::HeroImage'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.first.type).to match("Aypex::Cms::Component::HeroImage")
    end

    it "creates 1 cms_component" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.count).to eq 1
    end

    it "#gutters? is false" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.gutters?).to be false
    end

    it "#full_screen? is false" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.full_screen?).to be false
    end
  end
end
