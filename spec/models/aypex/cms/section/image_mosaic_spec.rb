require "spec_helper"

describe Aypex::Cms::Section::ImageMosaic do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }

  context "when a new Featured Article section is created" do
    let(:target_section) { create(:cms_section_image_mosaic, cms_page: homepage) }

    it "sets .has_gutters to be false" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.has_gutters).to be true
    end

    it "sets .is_full_screen to be true" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.is_full_screen).to be false
    end

    it "creates cms_component with 'Aypex::Cms::Component::ImageMosaic'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.first.type).to match("Aypex::Cms::Component::ImageMosaic")
    end

    it "creates 3 cms_components" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.count).to eq 3
    end
  end
end
