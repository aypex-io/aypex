require "spec_helper"

module Aypex
  module Calculator::Shipping
    describe FlexiRate do
      let(:variant1) { build(:variant, price: 10) }
      let(:variant2) { build(:variant, price: 20) }

      let(:package) do
        build(:stock_package, variants_contents: {variant1 => 4, variant2 => 6})
      end

      let(:subject) { FlexiRate.new }

      context "compute" do
        it "computes amount correctly when all fees are 0" do
          expect(subject.compute(package).round(2)).to eq(0.0)
        end

        it "computes amount correctly when first_item has a value" do
          subject.first_item = 1.0
          expect(subject.compute(package).round(2)).to eq(1.0)
        end

        it "computes amount correctly when additional_items has a value" do
          subject.additional_item = 1.0
          expect(subject.compute(package).round(2)).to eq(9.0)
        end

        it "computes amount correctly when additional_items and first_item have values" do
          subject.first_item = 5.0
          subject.additional_item = 1.0
          expect(subject.compute(package).round(2)).to eq(14.0)
        end

        it "computes amount correctly when additional_items and first_item have values AND max items has value" do
          subject.first_item = 5.0
          subject.additional_item = 1.0
          subject.max_items = 3
          expect(subject.compute(package).round(2)).to eq(7.0)
        end

        it "allows creation of new object with all the attributes" do
          FlexiRate.new(
            first_item: 1,
            additional_item: 1,
            max_items: 1
          )
        end
      end
    end
  end
end
