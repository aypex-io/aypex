require "spec_helper"

module Aypex
  describe QueryFilters::Comparable do
    let(:subject) do
      described_class.new(attribute: Aypex::DummyModel.arel_table[:position])
    end

    let!(:dummy1) { Aypex::DummyModel.create(name: "1", position: 3) }
    let!(:dummy2) { Aypex::DummyModel.create(name: "2", position: 10) }
    let!(:dummy3) { Aypex::DummyModel.create(name: "3", position: 4) }
    let(:scope) { Aypex::DummyModel.all }

    context "with greater than matcher" do
      let(:filter) do
        {
          position: {gt: 3}
        }
      end

      it "returns correct dummies" do
        result = subject.call(scope: scope, filter: filter[:position])
        expect(result).to include(dummy2, dummy3)
        expect(result).not_to include(dummy1)
      end
    end

    context "with greater than or equal matcher" do
      let(:filter) do
        {
          position: {gteq: 4}
        }
      end

      it "returns correct dummies" do
        result = subject.call(scope: scope, filter: filter[:position])
        expect(result).to include(dummy2, dummy3)
        expect(result).not_to include(dummy1)
      end
    end

    context "with lower than matcher" do
      let(:filter) do
        {
          position: {lt: 4}
        }
      end

      it "returns correct dummies" do
        result = subject.call(scope: scope, filter: filter[:position])
        expect(result).to include(dummy1)
        expect(result).not_to include(dummy2, dummy3)
      end
    end

    context "with lower than or equal matcher" do
      let(:filter) do
        {
          position: {lteq: 4}
        }
      end

      it "returns correct dummies" do
        result = subject.call(scope: scope, filter: filter[:position])
        expect(result).to include(dummy1, dummy3)
        expect(result).not_to include(dummy2)
      end
    end
  end
end
