require "spec_helper"

module Aypex
  # Regression tests for #2179
  describe OrderMerger do
    let(:variant) { create(:variant) }
    let(:order_1) { Aypex::Order.create }
    let(:order_2) { Aypex::Order.create }
    let(:user) { create(:user) }
    let(:subject) { Aypex::OrderMerger.new(order_1) }

    it "destroys the other order" do
      subject.merge!(order_2)
      expect { order_2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "persist the merge" do
      expect(subject).to receive(:persist_merge)
      subject.merge!(order_2)
    end

    context "user is provided" do
      it "assigns user to new order" do
        subject.merge!(order_2, user)
        expect(order_1.user).to eq user
      end
    end

    context "merging together two orders with line items for the same variant" do
      before do
        Aypex::Cart::AddItem.call order: order_1, variant: variant, quantity: 1
        Aypex::Cart::AddItem.call order: order_2, variant: variant, quantity: 1
      end

      specify do
        subject.merge!(order_2, user)
        expect(order_1.line_items.count).to eq(1)

        line_item = order_1.line_items.first
        expect(line_item.quantity).to eq(2)
        expect(line_item.variant_id).to eq(variant.id)
      end
    end

    context "merging using extension-specific line_item_comparison_hooks" do
      before do
        Rails.application.config.aypex.line_item_comparison_hooks << :foos_match
        allow(Aypex::Variant).to receive(:price_modifier_amount).and_return(0.00)
      end

      after do
        # reset to avoid test pollution
        Rails.application.config.aypex.line_item_comparison_hooks = Set.new
      end

      context "2 equal line items" do
        before do
          @line_item_1 = Aypex::Cart::AddItem.call(order: order_1, variant: variant, quantity: 1, options: {foos: {}}).value
          @line_item_2 = Aypex::Cart::AddItem.call(order: order_2, variant: variant, quantity: 1, options: {foos: {}}).value
        end

        specify do
          expect(order_1).to receive(:foos_match).with(@line_item_1, kind_of(Hash)).and_return(true)
          subject.merge!(order_2)
          expect(order_1.line_items.count).to eq(1)

          line_item = order_1.line_items.first
          expect(line_item.quantity).to eq(2)
          expect(line_item.variant_id).to eq(variant.id)
        end
      end

      context "2 different line items" do
        before do
          allow(order_1).to receive(:foos_match).and_return(false)

          Aypex::Cart::AddItem.call order: order_1, variant: variant, quantity: 1, options: {foos: {}}
          Aypex::Cart::AddItem.call order: order_2, variant: variant, quantity: 1, options: {foos: {}}
        end

        specify do
          subject.merge!(order_2)
          expect(order_1.line_items.count).to eq(2)

          line_item = order_1.line_items.first
          expect(line_item.quantity).to eq(1)
          expect(line_item.variant_id).to eq(variant.id)

          line_item = order_1.line_items.last
          expect(line_item.quantity).to eq(1)
          expect(line_item.variant_id).to eq(variant.id)
        end
      end
    end

    context "merging together two orders with different line items" do
      let(:variant_2) { create(:variant) }

      before do
        Aypex::Cart::AddItem.call order: order_1, variant: variant, quantity: 1
        Aypex::Cart::AddItem.call order: order_2, variant: variant_2, quantity: 1
      end

      specify do
        subject.merge!(order_2)
        line_items = order_1.line_items.reload
        expect(line_items.count).to eq(2)

        expect(order_1.item_count).to eq 2
        expect(order_1.item_total).to eq line_items.map(&:amount).sum

        # No guarantee on ordering of line items, so we do this:
        expect(line_items.pluck(:quantity)).to match_array([1, 1])
        expect(line_items.pluck(:variant_id)).to match_array([variant.id, variant_2.id])
      end
    end

    context "merging together orders with invalid line items" do
      let(:variant_2) { create(:variant) }

      before do
        Aypex::Cart::AddItem.call order: order_1, variant: variant, quantity: 1
        Aypex::Cart::AddItem.call order: order_2, variant: variant_2, quantity: 1
      end

      it "creates errors with invalid line items" do
        variant_2.destroy!
        subject.merge!(order_2)
        expect(order_1.errors.full_messages).not_to be_empty
      end
    end
  end
end
