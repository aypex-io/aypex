require "spec_helper"

describe Aypex::Promotion::Actions::CreateItemAdjustments do
  let(:order) { create(:order) }
  let(:promotion) { create(:promotion) }
  let(:action) { described_class.new }
  let!(:line_item) { create(:line_item, order:) }
  let(:payload) { {order:, promotion:} }

  before do
    allow(action).to receive(:promotion).and_return(promotion)
    promotion.promotion_actions = [action]
  end

  it_behaves_like "an adjustment source"

  describe "#perform" do
    # Regression test for #3966
    context "when calculator computes 0" do
      before do
        allow(action).to receive_messages compute_amount: 0
      end

      it "does not create an adjustment when calculator returns 0" do
        action.perform(payload)
        expect(action.adjustments).to be_empty
      end
    end

    context "when calculator returns a non-zero value" do
      before do
        promotion.promotion_actions = [action]
        allow(action).to receive_messages compute_amount: 10
      end

      it "creates adjustment with item as adjustable" do
        action.perform(payload)
        expect(action.adjustments.count).to eq(1)
        expect(line_item.reload.adjustments).to eq(action.adjustments)
      end

      it "creates adjustment with self as source" do
        action.perform(payload)
        expect(line_item.reload.adjustments.first.source).to eq action
      end

      it "does not perform twice on the same item" do
        2.times { action.perform(payload) }
        expect(action.adjustments.count).to eq(1)
      end

      context "with products rules" do
        let!(:second_line_item) { create(:line_item, order:) }
        let(:rule) { double Aypex::Promotion::Rules::Product }

        before do
          allow(promotion).to receive(:eligible_rules) { [rule] }
          allow(rule).to receive(:actionable?).and_return(true, false)
        end

        it "does not create adjustments for line_items not in product rule" do
          action.perform(payload)
          expect(action.adjustments.count).to be 1
          expect(line_item.reload.adjustments).to match_array action.adjustments
          expect(second_line_item.reload.adjustments).to be_empty
        end
      end
    end
  end

  describe "#compute_amount" do
    before { promotion.promotion_actions = [action] }

    context "when the adjustable is actionable" do
      it "calls compute on the calculator" do
        allow(action.calculator).to receive(:compute).and_return(10)
        expect(action.calculator).to receive(:compute).with(line_item, actionable_items_total: 10, last_actionable_item: line_item, ams: [])
        action.compute_amount(line_item)
      end

      context "calculator returns amount greater than item total" do
        before do
          allow(action.calculator).to receive(:compute).with(line_item, actionable_items_total: 10, last_actionable_item: line_item, ams: []).and_return(300)
          allow(line_item).to receive_messages(amount: 100)
        end

        it "does not exceed it" do
          expect(action.compute_amount(line_item)).to be(-100)
        end
      end
    end

    context "when the adjustable is not actionable" do
      before { allow(promotion).to receive(:line_item_actionable?).and_return(false) }

      it "returns 0" do
        expect(action.compute_amount(line_item)).to be(0)
      end
    end
  end

  describe "#destroy" do
    let(:order) { create(:order) }
    let(:completed_order) { create(:completed_order_with_totals) }
    let!(:action) { described_class.create! }

    before { promotion.promotion_actions = [action] }

    it "destroys adjustments for uncompleted orders" do
      action.adjustments.create!(label: "Check",
        amount: 0,
        order:,
        adjustable: line_item)

      expect do
        action.destroy
      end.to change { action.adjustments.count }.by(-1)
    end

    it "nullifies adjustments for completed orders" do
      adjustment = action.adjustments.create!(label: "Check",
        amount: 0,
        order: completed_order,
        adjustable: line_item)

      expect do
        action.destroy
      end.to change { adjustment.reload.source_id }.from(action.id).to nil
    end
  end
end
