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

    context "when gravity is not set to centre" do
      let(:gravity) { "north" }

      it "attachment.variant should receive the unchanged value of gravity" do
        expect(image.attachment).to receive(:variant).with(resize_and_pad: [48, 48, gravity: "north"], saver: anything)
        image.generate_url(size: "48x48", gravity: gravity)
      end
    end

    context "when gravity is set to centre" do
      let(:image) { create(:image, viewable: variant) }

      it 'attachment.variant should receive "gravity: center" when image processing variant is nil' do
        allow(Rails.application.config.active_storage).to receive(:variant_processor).and_return(nil)
        expect(image.attachment).to receive(:variant).with(resize_and_pad: [48, 48, gravity: "center"], saver: anything)
        image.generate_url(size: "48x48")
      end

      it "returns center when image processing variant is mini magick" do
        allow(Rails.application.config.active_storage).to receive(:variant_processor).and_return(:mini_magick)
        expect(image.attachment).to receive(:variant).with(resize_and_pad: [48, 48, gravity: "center"], saver: anything)
        image.generate_url(size: "48x48")
      end

      it "returns centre when image processing variant is VIPS" do
        allow(Rails.application.config.active_storage).to receive(:variant_processor).and_return(:vips)
        expect(image.attachment).to receive(:variant).with(resize_and_pad: [48, 48, gravity: "centre"], saver: anything)
        image.generate_url(size: "48x48")
      end
    end
  end
end
