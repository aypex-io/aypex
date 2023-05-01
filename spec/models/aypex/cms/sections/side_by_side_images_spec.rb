require "spec_helper"

describe Aypex::Cms::Section::SideBySideImages do
  let!(:store) { create(:store) }
  let!(:homepage) { create(:cms_homepage, store: store) }

  it "validates presence of name" do
    expect(described_class.new(name: nil, cms_page: homepage)).not_to be_valid
  end

  it "validates presence of page" do
    expect(described_class.new(name: "Got Name")).not_to be_valid
  end

  context "when a new Image Gallery section is created" do
    let!(:side_by_side_images_section) { create(:cms_side_by_side_images_section, cms_page: homepage) }

    it "sets link_type_one to Aypex::Category" do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      expect(section.content[:link_type_one]).to eq("Aypex::Category")
    end

    it "sets link_type_two to Aypex::Category" do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      expect(section.content[:link_type_two]).to eq("Aypex::Category")
    end

    it "sets fit to Container" do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      expect(section.fit).to eq("Container")
    end

    it "#fullscreen? is true" do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      expect(section.fullscreen?).to be false
    end

    it "#gutters? is true" do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      expect(section.gutters?).to be true
    end
  end

  context "when changing the link types for links one and two" do
    let!(:side_by_side_images_section) { create(:cms_side_by_side_images_section, cms_page: homepage) }

    before do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      section.content[:link_type_one] = "Aypex::Product"
      section.content[:link_type_two] = "Aypex::Product"

      section.content[:link_one] = "Shirt 1"
      section.content[:link_two] = "Shirt 2"

      section.save!
      section.reload
    end

    it "link_one and link_two save the values correctly" do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      expect(section.link_one).to eql "Shirt 1"
      expect(section.link_two).to eql "Shirt 2"
    end

    it "link_one and link_two are reset to nil when type is changed" do
      section = Aypex::CmsSection.find(side_by_side_images_section.id)

      section.content[:link_type_one] = "Aypex::Category"
      section.content[:link_type_two] = "Aypex::Category"
      section.save!
      section.reload

      expect(section.link_one).to be_nil
      expect(section.link_two).to be_nil
    end
  end
end
