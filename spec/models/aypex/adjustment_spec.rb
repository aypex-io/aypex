require "spec_helper"

describe Aypex::Adjustment do
  let(:order) { Aypex::Order.new }
  let(:adjustment) { described_class.create!(label: "Adjustment", adjustable: order, order:, amount: 5) }

  before do
    allow(order).to receive(:update_with_updater!)
  end

  describe "#amount=" do
    let(:amount) { "1,599,99" }

    before { adjustment.amount = amount }

    it "is expected to equal to localized number" do
      expect(adjustment.amount).to eq(Aypex::LocalizedNumber.parse(amount))
    end
  end

  describe "scopes" do
    describe ".for_complete_order" do
      subject { described_class.for_complete_order }

      let(:complete_order) { Aypex::Order.create! completed_at: Time.current }
      let(:incomplete_order) { Aypex::Order.create! completed_at: nil }
      let(:adjustment_for_complete_order) { described_class.create!(label: "Adjustment", adjustable: complete_order, order: complete_order, amount: 5) }
      let(:adjustment_for_incomplete_order) { described_class.create!(label: "Adjustment", adjustable: incomplete_order, order: incomplete_order, amount: 5) }

      it { is_expected.to include(adjustment_for_complete_order) }
      it { is_expected.not_to include(adjustment_for_incomplete_order) }
    end

    describe ".for_incomplete_order" do
      subject { described_class.for_incomplete_order }

      let(:complete_order) { Aypex::Order.create! completed_at: Time.current }
      let(:incomplete_order) { Aypex::Order.create! completed_at: nil }
      let(:adjustment_for_complete_order) { described_class.create!(label: "Adjustment", adjustable: complete_order, order: complete_order, amount: 5) }
      let(:adjustment_for_incomplete_order) { described_class.create!(label: "Adjustment", adjustable: incomplete_order, order: incomplete_order, amount: 5) }

      it { is_expected.not_to include(adjustment_for_complete_order) }
      it { is_expected.to include(adjustment_for_incomplete_order) }
    end
  end

  describe "#create & #destroy" do
    let(:adjustment) { described_class.new(label: "Adjustment", amount: 5, order:, adjustable: create(:line_item)) }

    it "calls #update_adjustable_adjustment_total" do
      expect(adjustment).to receive(:update_adjustable_adjustment_total).twice
      adjustment.save
      adjustment.destroy
    end
  end

  describe "#save" do
    let(:order) { create(:order) }
    let!(:adjustment) { described_class.create(label: "Adjustment", amount: 5, order:, adjustable: order) }

    it "touches the adjustable" do
      expect(adjustment.adjustable).to receive(:touch)
      adjustment.amount = 3
      adjustment.save
    end
  end

  describe "non_tax scope" do
    subject do
      described_class.non_tax.to_a
    end

    let!(:tax_adjustment) { create(:adjustment, order:, source: create(:tax_rate)) }
    let!(:non_tax_adjustment_with_source) { create(:adjustment, order:, source_type: "Aypex::Order", source_id: nil) }
    let!(:non_tax_adjustment_without_source) { create(:adjustment, order:, source: nil) }

    it "select non-tax adjustments" do
      expect(subject).not_to include tax_adjustment
      expect(subject).to include non_tax_adjustment_with_source
      expect(subject).to include non_tax_adjustment_without_source
    end
  end

  describe "competing_promos scope" do
    subject do
      described_class.competing_promos.to_a
    end

    before do
      allow_any_instance_of(described_class).to receive(:update_adjustable_adjustment_total).and_return(true)
    end

    let!(:promotion_adjustment) { create(:adjustment, order:, source_type: "Aypex::PromotionAction", source_id: nil) }
    let!(:custom_adjustment_with_source) { create(:adjustment, order:, source_type: "Custom", source_id: nil) }
    let!(:non_promotion_adjustment_with_source) { create(:adjustment, order:, source_type: "Aypex::Order", source_id: nil) }
    let!(:non_promotion_adjustment_without_source) { create(:adjustment, order:, source: nil) }

    context "no custom source_types have been added to competing_promos" do
      before { described_class.competing_promos_source_types = ["Aypex::PromotionAction"] }

      it "selects promotion adjustments by default" do
        expect(subject).to include promotion_adjustment
        expect(subject).not_to include custom_adjustment_with_source
        expect(subject).not_to include non_promotion_adjustment_with_source
        expect(subject).not_to include non_promotion_adjustment_without_source
      end
    end

    context "a custom source_type has been added to competing_promos" do
      before { described_class.competing_promos_source_types = ["Aypex::PromotionAction", "Custom"] }

      it "selects adjustments with registered source_types" do
        expect(subject).to include promotion_adjustment
        expect(subject).to include custom_adjustment_with_source
        expect(subject).not_to include non_promotion_adjustment_with_source
        expect(subject).not_to include non_promotion_adjustment_without_source
      end
    end
  end

  context "adjustment state" do
    let(:adjustment) { create(:adjustment, order:, state: "open") }

    describe "#closed?" do
      it "is true when adjustment state is closed" do
        adjustment.state = "closed"
        expect(adjustment).to be_closed
      end

      it "is false when adjustment state is open" do
        adjustment.state = "open"
        expect(adjustment).not_to be_closed
      end
    end
  end

  describe "#currency" do
    let(:order) { Aypex::Order.new(currency: "EUR") }

    it "returns the order currency" do
      expect(adjustment.currency).to eq "EUR"
    end
  end

  describe "#display_amount" do
    before { adjustment.amount = 10.55 }

    it "shows the amount" do
      expect(adjustment.display_amount.to_s).to eq "$10.55"
    end

    context "with currency set to JPY" do
      context "when adjustable is set to an order" do
        before do
          allow(order).to receive(:currency).and_return("JPY")
          adjustment.adjustable = order
        end

        it "displays in JPY" do
          expect(adjustment.display_amount.to_s).to eq "¥11"
        end
      end

      context "when adjustable is nil" do
        it "displays in the default currency" do
          expect(adjustment.display_amount.to_s).to eq "$10.55"
        end
      end
    end
  end

  describe "#update!" do
    subject { adjustment.update! }

    let(:adjustment) { described_class.create!(label: "Adjustment", order:, adjustable: order, amount: 5, state:, source:) }
    let(:source) { mock_model(Aypex::TaxRate, compute_amount: 10) }

    context "when adjustment is closed" do
      let(:state) { "closed" }

      it "does not update the adjustment" do
        expect(adjustment).not_to receive(:update_column)
        subject
      end
    end
  end
end
