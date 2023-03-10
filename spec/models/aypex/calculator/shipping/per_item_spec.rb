require "spec_helper"

module Aypex
  module Calculator::Shipping
    describe PerItem do
      subject { PerItem.new(amount: 10) }

      let(:variant1) { build(:variant) }
      let(:variant2) { build(:variant) }

      let(:package) do
        build(:stock_package, variants_contents: {variant1 => 5, variant2 => 3})
      end

      it "correctly calculates per item shipping" do
        expect(subject.compute(package).to_f).to eq(80) # 5 x 10 + 3 x 10
      end
    end
  end
end
