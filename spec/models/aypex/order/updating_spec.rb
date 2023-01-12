require "spec_helper"

describe Aypex::Order do
  let(:order) { create(:order) }

  context "#update_with_updater!" do
    let(:line_items) { create_list(:line_item, 1, amount: 5) }

    context "when there are update hooks" do
      before { Aypex::Order.register_update_hook :foo }

      after { Aypex::Order.update_hooks.clear }

      it "calls each of the update hooks" do
        expect(order).to receive :foo
        order.update_with_updater!
      end
    end
  end
end
