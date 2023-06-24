require "spec_helper"

describe Aypex::StoreIcon do
  describe "build" do
    let(:store_icon) { build(:store_icon) }

    it "creates image" do
      expect(store_icon.image.viewable_type).to eq "Aypex::StoreIcon"
    end
  end
end
