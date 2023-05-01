require "spec_helper"

describe Aypex::Cms::Section::ImageGallery do
  let(:store) { create(:store) }
  let(:homepage) { create(:cms_homepage, store: store) }

  context "when a new Featured Article section is created" do
    let(:target_section) { create(:cms_image_gallery_section, cms_page: homepage) }

    it "sets gutters to 'With Gutters'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.gutters).to eq("With Gutters")
    end

    it "sets fit to 'Fit to Container'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.fit).to eq("Fit to Container")
    end

    it "creates cms_component with 'Aypex::Cms::Component::ImageGallery'" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.first.type).to match("Aypex::Cms::Component::ImageGallery")
    end

    it "creates 3 cms_components" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.cms_components.count).to eq 3
    end

    it "#gutters? is true" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.gutters?).to be true
    end

    it "#full_screen? is false" do
      section = Aypex::CmsSection.find(target_section.id)

      expect(section.full_screen?).to be false
    end
  end
end
