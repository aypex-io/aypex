require "spec_helper"

describe Aypex::Calculator::Promotion::FixedAmount do
  let(:calculator) { described_class.new }
  let(:order) { create(:order, currency: "USD") }

  let(:line_item_1) { create(:line_item, order:, currency: "USD", price: 64.65) }
  let(:line_item_2) { create(:line_item, order:, currency: "USD", price: 22.98) }
  let(:line_item_3) { create(:line_item, order:, currency: "USD", price: 10.90) }

  before { allow(calculator).to receive_messages amount: 10 }

  context "compute" do
    it "uses the correct amount on line item 1" do
      target_item = line_item_1
      actionable_items_total = (line_item_1.price + line_item_2.price + line_item_3.price)
      last_actionable_item = line_item_3
      ams = [line_item_1.price, line_item_2.price]

      options = {
        actionable_items_total:,
        last_actionable_item:,
        ams:
      }

      expect(calculator.compute(target_item, **options)).to eq 6.56
    end

    it "uses the correct amount on line item 2" do
      target_item = line_item_2
      actionable_items_total = (line_item_1.price + line_item_2.price + line_item_3.price)
      last_actionable_item = line_item_3
      ams = [line_item_1.price, line_item_2.price]

      options = {
        actionable_items_total:,
        last_actionable_item:,
        ams:
      }

      expect(calculator.compute(target_item, **options)).to eq 2.33
    end

    it "uses the correct amount on line item 3" do
      target_item = line_item_3
      actionable_items_total = (line_item_1.price + line_item_2.price + line_item_3.price)
      last_actionable_item = line_item_3
      ams = [line_item_1.price, line_item_2.price]

      options = {
        actionable_items_total:,
        last_actionable_item:,
        ams:
      }

      expect(calculator.compute(target_item, **options)).to eq 1.11

      # 6.56 + 2.33 + 1.11 = 10 (the amount)
    end

    it "picks up the remainder on the last item to give $10 off exactly" do
      # The prices below are specifically set to cause a rounding error,
      # causing the discount to total 10.01, but the code looks for the last item id
      # to be applicable for discount -> line_item_3.id
      # and picks up the spare giving us the perfect 10 discount every time.

      # Do not change these values.
      line_item_1.price = 64.65
      line_item_2.price = 22.98
      line_item_3.price = 23.09

      actionable_items_total = (line_item_1.price + line_item_2.price + line_item_3.price)
      ams = [line_item_1.price, line_item_2.price]

      expect((calculator.compute(line_item_1, actionable_items_total:, last_actionable_item: line_item_3, ams:) + calculator.compute(line_item_2, actionable_items_total:, last_actionable_item: line_item_3, ams:) + calculator.compute(line_item_3, actionable_items_total:, last_actionable_item: line_item_3, ams:)).to_f).to eq 10
    end
  end
end
