require "spec_helper"

describe Aypex::Promotion::Rules::Category, type: :model do
  let(:rule) { subject }

  let(:store) { create(:store) }

  describe "#eligible?(order)" do
    let(:base_category) { create(:base_category, store: store) }
    let(:category) { create(:category, name: "first", base_category: base_category) }
    let(:category2) { create(:category, name: "second", base_category: base_category) }
    let(:order) { create(:order_with_line_items, store: store) }

    before do
      rule.save
    end

    context "with any match policy" do
      before do
        rule.match_policy = "any"
      end

      it "is eligible if order does has any preferred category" do
        order.products.first.categories << category
        rule.categories << category
        expect(rule).to be_eligible(order)
      end

      context "when order contains items from different categories" do
        before do
          order.products.first.categories << category
          rule.categories << category
        end

        it "acts on a product within the eligible category" do
          expect(rule).to be_actionable(order.line_items.last)
        end

        it "does not act on a product in another category" do
          order.line_items << create(:line_item, product: create(:product, categories: [category2], stores: [store]))
          expect(rule).not_to be_actionable(order.line_items.last)
        end
      end

      context "when order does not have any preferred category" do
        before { rule.categories << category2 }

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "You need to add a product from an applicable category before applying this coupon code."
        end
      end

      context "when a product has a category child of a category rule" do
        before do
          category.children << category2
          order.products.first.categories << category2
          rule.categories << category2
        end

        it { expect(rule).to be_eligible(order) }
      end
    end

    context "with all match policy" do
      before do
        rule.match_policy = "all"
      end

      it "is eligible order has all preferred categories" do
        order.products.first.categories << category2
        order.products.last.categories << category

        rule.categories = [category, category2]

        expect(rule).to be_eligible(order)
      end

      context "when order does not have all preferred categories" do
        before { rule.categories << category }

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "You need to add a product from all applicable categories before applying this coupon code."
        end
      end

      context "when a product has a category child of a category rule" do
        let(:category3) { create(:category, base_category: base_category) }

        before do
          category.children << category2
          order.products.first.categories << category2
          order.products.last.categories << category3
          rule.categories << category2
          rule.categories << category3
        end

        it { expect(rule).to be_eligible(order) }
      end
    end
  end
end
