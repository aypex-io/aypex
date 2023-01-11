require "spec_helper"

describe Aypex::Image, type: :model do
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

  describe "#styles" do
    it "will return all styles for the image" do
      aypex_image.attachment.attach(io: image_file, filename: "thinking-cat.jpg", content_type: "image/jpeg")
      res = aypex_image.styles

      expect(res.length).to eq described_class.styles.keys.length
    end
  end

  describe "#style" do
    it "will return style for the given name" do
      aypex_image.attachment.attach(io: image_file, filename: "thinking-cat.jpg", content_type: "image/jpeg")
      styles = described_class.styles.keys
      random_style_name = styles.sample
      res = aypex_image.style(random_style_name)

      expect(res[:size]).to eq described_class.styles[random_style_name]
    end
  end
end
