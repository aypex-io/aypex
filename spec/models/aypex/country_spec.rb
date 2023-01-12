require "spec_helper"

describe Aypex::Country do
  let(:store) { create(:store, default: true, default_country: america) }
  let(:america) { create(:country) }
  let(:canada) { create(:country, name: "Canada", iso_name: "CANADA", iso: "CA", iso3: "CAN", numcode: "124") }

  it "validates uniqueness" do
    canada.touch
    expect(Aypex::Country.new(name: "Canada", iso: "CA", iso3: "CAN", iso_name: "CANADA")).not_to be_valid
  end

  describe ".by_iso" do
    let(:dummy_iso) { "XY" }

    it "will return Country by iso" do
      expect(described_class.by_iso(america.iso)).to eq america
    end

    it "will return Country by iso3" do
      expect(described_class.by_iso(america.iso3)).to eq america
    end

    it "will return nil with wrong iso or iso3" do
      expect(described_class.by_iso(dummy_iso)).to eq nil
    end

    it "will return Country by lower iso" do
      expect(described_class.by_iso(america.iso.downcase)).to eq america
    end
  end

  describe "#default?" do
    before do
      allow_any_instance_of(Aypex::Store).to receive(:default).and_return(store)
    end

    context "no arguments" do
      it "returns true for store default country" do
        expect(america.default?).to eq(true)
      end

      it "returns false for other countries" do
        expect(canada.default?).to eq(false)
      end
    end

    context "other store passed" do
      let(:other_store) { create(:store, default_country: canada) }

      it "returns true for store default country" do
        expect(canada.default?(other_store)).to eq(true)
      end

      it "returns false for other countries" do
        expect(america.default?(other_store)).to eq(false)
      end
    end
  end
end
