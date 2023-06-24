require "spec_helper"

describe Aypex::Image do
  let(:aypex_image) { described_class.new }
  let(:image_file) { File.open("#{Aypex::Engine.root}/spec/fixtures/files/square.jpg") }
  let(:text_file) { File.open("#{Aypex::Engine.root}/spec/fixtures/files/text-file.txt") }

  describe "validation" do
    context "when attachment is absent" do
      it "is invalid" do
        aypex_image.attachment.attach(nil)
        expect(aypex_image).not_to be_valid
      end
    end

    context "when attachment is an allowed content type" do
      it "is valid" do
        aypex_image.attachment.attach(io: image_file, filename: "square.jpg", content_type: "image/jpeg")
        expect(aypex_image).to be_valid
      end
    end

    context "when attachment is an disallowed content type" do
      it "is returns invalid" do
        aypex_image.attachment.attach(io: text_file, filename: "text-file.txt", content_type: "text/plain")
        expect(aypex_image).not_to be_valid
      end
    end
  end

  describe "#generate_url" do
    let(:variant) { create(:variant) }
    let(:image) { create(:image, viewable: variant) }

    before do
      allow(image).to receive(:cdn_image_url)
    end

    context "when format is set to the same as existing format" do
      it "receives the unchanged value of gravity" do
        expect(image.attachment).to receive(:variant).with(resize_to_limit: [48, nil], saver: {quality: 100}, convert: "jpeg")
        image.generate_url(width: 48, format: :jpeg)
      end
    end

    context "when format is converted from jpeg to png" do
      it "receives the format and changes the variant" do
        expect(image.attachment).to receive(:variant).with(resize_to_limit: [48, nil], saver: {quality: 100}, convert: "png")
        image.generate_url(width: 48, format: :png)
      end
    end
  end
end
