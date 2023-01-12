require "spec_helper"

module Aypex
  module Calculator::Shipping
    describe FlatRate do
      subject { Calculator::Shipping::FlatRate.new(amount: 4.00) }

      it "always returns the same rate" do
        expect(subject.compute(build(:stock_package_fulfilled))).to eq(4.00)
      end
    end
  end
end
