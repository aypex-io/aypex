require "spec_helper"

describe Aypex::Asset::Validate::ImageSquarePng do
  describe "validations" do
    it "validates image is square" do
      expect(build(:asset_image_square_png, filepath: file_fixture("img.png"))).not_to be_valid
    end

    it "allows .png files" do
      expect(build(:asset_image_square_png, filepath: file_fixture("square.png"))).to be_valid
    end

    it "allows .gif files" do
      expect(build(:asset_image_square_png, filepath: file_fixture("square.gif"))).not_to be_valid
    end
  end
end
