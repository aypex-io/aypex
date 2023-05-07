require "spec_helper"

describe Aypex::Cms::Section::ImageHero do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }

  context "when a new ImageHero Image section is created" do
    let(:target_section) { create(:cms_section_image_hero, cms_page: homepage) }

    it "sets .has_gutters to be false" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.has_gutters).to be false
    end

    it "sets .is_full_screen to be true" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.is_full_screen).to be true
    end

    it "creates no cms_component" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.count).to eq 0
    end
  end
end
