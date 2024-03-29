require "spec_helper"

describe Aypex::Price do
  describe "#amount=" do
    let(:price) { build(:price) }
    let(:amount) { "3,0A0" }

    before do
      price.amount = amount
    end

    it "is expected to equal to localized number" do
      expect(price.amount).to eq(Aypex::LocalizedNumber.parse(amount))
    end
  end

  describe "#compared_amount=" do
    let(:price) { build(:price) }
    let(:compared_amount) { "169.99" }

    before do
      price.compared_amount = compared_amount
    end

    it "is expected to equal to localized number" do
      expect(price.compared_amount).to eq(Aypex::LocalizedNumber.parse(compared_amount))
    end
  end

  describe "#price" do
    let(:price) { build(:price) }
    let(:amount) { 3000.00 }

    context "when amount is changed" do
      before do
        price.amount = amount
      end

      it "is expected to equal to price" do
        expect(price.amount).to eq(price.price)
      end
    end
  end

  describe "#compared_price" do
    let(:price) { build(:price) }
    let(:compared_amount) { 3000.00 }

    context "when amount is changed" do
      before do
        price.compared_amount = compared_amount
      end

      it "is expected to equal to price" do
        expect(price.compared_amount).to eq(price.compared_price)
      end
    end
  end

  describe "validations" do
    subject { build(:price, variant: variant, amount: amount) }

    let(:variant) { create(:variant) }

    context "when the amount is nil" do
      let(:amount) { nil }

      it { is_expected.to be_valid }
    end

    context "when the amount is less than 0" do
      let(:amount) { -1 }

      before { subject.valid? }

      it "has 1 error on amount" do
        expect(subject.errors.messages[:amount].size).to eq(1)
      end

      it "populates errors" do
        expect(subject.errors.messages[:amount].first).to eq "must be greater than or equal to 0"
      end
    end

    context "when the amount is greater than maximum amount" do
      let(:amount) { Aypex::Price::MAXIMUM_AMOUNT + 1 }

      before { subject.valid? }

      it "has 1 error on amount" do
        expect(subject.errors.messages[:amount].size).to eq(1)
      end

      it "populates errors" do
        expect(subject.errors.messages[:amount].first).to eq "must be less than or equal to #{Aypex::Price::MAXIMUM_AMOUNT}"
      end
    end

    context "when the amount is between 0 and the maximum amount" do
      let(:amount) { Aypex::Price::MAXIMUM_AMOUNT }

      it { is_expected.to be_valid }
    end
  end

  describe "#price_including_vat_for(zone)" do
    subject(:price_with_vat) { price.price_including_vat_for(price_options) }

    let(:variant) { create(:variant) }
    let(:default_zone) { Aypex::Zone.new }
    let(:zone) { Aypex::Zone.new }
    let(:amount) { 10 }
    let(:tax_category) { Aypex::TaxCategory.new }
    let(:price) { build(:price, variant: variant, amount: amount) }
    let(:price_options) { {tax_zone: zone} }

    context "when called with a non-default zone" do
      before do
        allow(variant).to receive(:tax_category).and_return(tax_category)
        expect(price).to receive(:default_zone).at_least(:once).and_return(default_zone)
        allow(price).to receive(:apply_foreign_vat?).and_return(true)
        allow(price).to receive(:included_tax_amount).with({tax_zone: default_zone, tax_category: tax_category}).and_return(0.19)
        allow(price).to receive(:included_tax_amount).with({tax_zone: zone, tax_category: tax_category}).and_return(0.25)
      end

      it "returns the correct price including another VAT to two digits" do
        expect(price_with_vat).to eq(10.50)
      end
    end

    context "when called from the default zone" do
      before do
        allow(variant).to receive(:tax_category).and_return(tax_category)
        expect(price).to receive(:default_zone).at_least(:once).and_return(zone)
      end

      it "returns the correct price" do
        expect(price).to receive(:price).and_call_original
        expect(price_with_vat).to eq(10.00)
      end
    end

    context "when no default zone is set" do
      before do
        allow(variant).to receive(:tax_category).and_return(tax_category)
        expect(price).to receive(:default_zone).at_least(:once).and_return(nil)
      end

      it "returns the correct price" do
        expect(price).to receive(:price).and_call_original
        expect(price.price_including_vat_for(tax_zone: zone)).to eq(10.00)
      end
    end
  end

  describe "#compared_price_including_vat_for(zone)" do
    subject(:compared_price_with_vat) { price.compared_price_including_vat_for(price_options) }

    let(:variant) { create(:variant) }
    let(:default_zone) { Aypex::Zone.new }
    let(:zone) { Aypex::Zone.new }
    let(:amount) { 10 }
    let(:compared_amount) { 100 }
    let(:tax_category) { Aypex::TaxCategory.new }
    let(:price) { build(:price, variant: variant, amount: amount, compared_amount: compared_amount) }
    let(:price_options) { {tax_zone: zone} }

    context "when called with a non-default zone" do
      before do
        allow(variant).to receive(:tax_category).and_return(tax_category)
        expect(price).to receive(:default_zone).at_least(:once).and_return(default_zone)
        allow(price).to receive(:apply_foreign_vat?).and_return(true)
        allow(price).to receive(:included_tax_amount).with({tax_zone: default_zone, tax_category: tax_category}).and_return(0.19)
        allow(price).to receive(:included_tax_amount).with({tax_zone: zone, tax_category: tax_category}).and_return(0.25)
      end

      it "returns the correct price including another VAT to two digits" do
        expect(compared_price_with_vat).to eq(105.04)
      end
    end

    context "when called from the default zone" do
      before do
        allow(variant).to receive(:tax_category).and_return(tax_category)
        expect(price).to receive(:default_zone).at_least(:once).and_return(zone)
      end

      it "returns the correct price" do
        expect(price).to receive(:compared_price).and_call_original
        expect(compared_price_with_vat).to eq(100.00)
      end
    end

    context "when no default zone is set" do
      before do
        allow(variant).to receive(:tax_category).and_return(tax_category)
        expect(price).to receive(:default_zone).at_least(:once).and_return(nil)
      end

      it "returns the correct price" do
        expect(price).to receive(:compared_price).and_call_original
        expect(price.compared_price_including_vat_for(tax_zone: zone)).to eq(100.00)
      end
    end
  end

  describe "#display_amount_inc_vat(zone)" do
    subject { build(:price, amount: 10) }

    it "calls #amount_inc_vat" do
      expect(subject).to receive(:amount_inc_vat)
      subject.display_amount_inc_vat(nil)
    end
  end

  describe "#display_compared_amount_inc_vat(zone)" do
    subject { build(:price, amount: 10, compared_amount: 100) }

    it "calls #compared_amount_inc_vat" do
      expect(subject).to receive(:compared_amount_inc_vat)
      subject.display_compared_amount_inc_vat(nil)
    end
  end
end
