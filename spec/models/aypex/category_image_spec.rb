require "spec_helper"

describe Aypex::CategoryImage, type: :model do
  context "validation" do
    let(:aypex_image) { Aypex::CategoryImage.new }
    let(:image_file) { File.open(Aypex::Engine.root + "spec/fixtures" + "thinking-cat.jpg") }
    let(:text_file) { File.open(Aypex::Engine.root + "spec/fixtures" + "text-file.txt") }

    it "has allowed attachment content type" do
      aypex_image.attachment.attach(io: image_file, filename: "thinking-cat.jpg", content_type: "image/jpeg")
      expect(aypex_image).to be_valid
    end

    it "has no allowed attachment content type" do
      aypex_image.attachment.attach(io: text_file, filename: "text-file.txt", content_type: "text/plain")
      expect(aypex_image).not_to be_valid
    end
  end
end
