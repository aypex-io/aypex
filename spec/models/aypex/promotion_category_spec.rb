require "spec_helper"

describe Aypex::PromotionCategory do
  describe "validation" do
    subject { Aypex::PromotionCategory.new name: name }

    let(:name) { "Nom" }

    context "when all required attributes are specified" do
      it { is_expected.to be_valid }
    end

    context "when name is missing" do
      let(:name) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
