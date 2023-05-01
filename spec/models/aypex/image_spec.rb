require "spec_helper"

describe Aypex::Image do
  let(:aypex_image) { described_class.new }
  let(:image_file) { File.open("#{Aypex::Engine.root}/spec/fixtures/thinking-cat.jpg") }
  let(:text_file) { File.open("#{Aypex::Engine.root}/spec/fixtures/text-file.txt") }

  context "validation" do
    it "has attachment present" do
      aypex_image.attachment.attach(io: image_file, filename: "thinking-cat.jpg")
      expect(aypex_image).to be_valid
    end

    it "has attachment absent" do
      aypex_image.attachment.attach(nil)
      expect(aypex_image).not_to be_valid
    end

    it "has allowed attachment content type" do
      aypex_image.attachment.attach(io: image_file, filename: "thinking-cat.jpg", content_type: "image/jpeg")
      expect(aypex_image).to be_valid
    end

    it "has no allowed attachment content type" do
      aypex_image.attachment.attach(io: text_file, filename: "text-file.txt", content_type: "text/plain")
      expect(aypex_image).not_to be_valid
    end
  end

  describe "#generate_url" do
    let(:variant) { create(:variant) }
    let(:image) { create(:image, viewable: variant) }

    before do
      allow(image).to receive(:cdn_image_url)
    end

    context "when format is not set to jpeg" do
      let(:gravity) { "north" }

      it "attachment.variant should receive the unchanged value of gravity" do
        expect(image.attachment).to receive(:variant).with(resize_to_limit: [48, nil], saver: anything, format: :jpeg, convert: :jpeg)
        image.generate_url(width: 48, format: :jpeg)
      end
    end
  end
end
