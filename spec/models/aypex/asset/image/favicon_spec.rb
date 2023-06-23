require "spec_helper"

describe Aypex::Asset::Image::Favicon do
  describe "validations" do
    it "validates image is square" do
      expect(build(:favicon_asset, filepath: file_fixture("img_256x128.png"))).not_to be_valid
    end

    it "allows .png files" do
      expect(build(:favicon_asset, filepath: file_fixture("icon_256x256.png"))).to be_valid
    end

    it "allows .gif files" do
      expect(build(:favicon_asset, filepath: file_fixture("icon_256x256.gif"))).not_to be_valid
    end

    describe "file size" do
      let(:favicon) do
        favicon_image = build(:favicon_asset)
        favicon_image.attachment.attach(io: file, filename: "favicon.png")
        favicon_image
      end

      let(:file) { File.open(file_fixture("icon_256x256.png")) }

      before do
        allow(file).to receive(:size).and_return(size)
      end

      context "when size is 1 megabyte" do
        let(:size) { 1.megabyte }

        it "is valid" do
          expect(favicon).to be_valid
        end
      end

      context "when size is over 1 megabyte" do
        let(:size) { 1.megabyte + 1 }

        it "is invalid" do
          expect(favicon).not_to be_valid
        end
      end
    end
  end
end
