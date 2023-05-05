require "spec_helper"

describe Aypex::Cms::Section::Hero do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }

  context "when a new Hero Image section is created" do
    let(:target_section) { create(:cms_hero_section, cms_page: homepage) }

    it "sets .has_gutters to be false" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.has_gutters).to be false
    end

    it "sets .is_full_screen to be true" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.is_full_screen).to be true
    end

    it "creates cms_component with 'Aypex::Cms::Component::Hero'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.first.type).to match("Aypex::Cms::Component::Hero")
    end

    it "creates 1 cms_component" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.count).to eq 1
    end
  end
end
