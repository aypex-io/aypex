require "spec_helper"

describe Aypex::StoreFavicon do
  describe "build" do
    let(:favicon) { build(:favicon) }

    it "creates image" do
      expect(favicon.image.viewable_type).to eq "Aypex::StoreFavicon"
    end
  end
end
