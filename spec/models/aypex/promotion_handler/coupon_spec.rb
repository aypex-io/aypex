require "spec_helper"

module Aypex
  module PromotionHandler
    describe Coupon do
      subject { Coupon.new(order) }

      let(:store) { Aypex::Store.default }
      let(:order) { double("Order", coupon_code: "10off", store: store).as_null_object }

      it "returns self in apply" do
        expect(subject.apply).to be_a Coupon
      end

      context "status messages" do
        let(:coupon) { Coupon.new(order) }

        describe "#set_success_code" do
          subject { coupon.set_success_code status }

          let(:status) { :coupon_code_applied }

          it "has status_code" do
            subject
            expect(coupon.status_code).to eq(status)
          end

          it "has success message" do
            subject
            expect(coupon.success).to eq(I18n.t(status, scope: :aypex))
          end
        end

        describe "#set_error_code" do
          subject { coupon.set_error_code status }

          let(:status) { :coupon_code_not_found }

          it "has status_code" do
            subject
            expect(coupon.status_code).to eq(status)
          end

          it "has error message" do
            subject
            expect(coupon.error).to eq(I18n.t(status, scope: :aypex))
          end
        end
      end

      context "coupon code promotion doesn't exist" do
        before { create(:promotion, name: "promo", code: nil) }

        it "doesn't fetch any promotion" do
          expect(subject.promotion).to be_blank
        end

        context "with no actions defined" do
          before { create(:promotion, name: "promo", code: "10off") }

          it "populates error message" do
            subject.apply
            expect(subject.error).to eq I18n.t(:coupon_code_not_found, scope: :aypex)
          end
        end
      end

      context "existing coupon code promotion" do
        let!(:promotion) { create(:promotion, :with_line_item_adjustment, adjustment_rate: 10, code: "10off", stores: [store]) }

        it "fetches with given code" do
          expect(subject.promotion).to eq promotion
        end

        context "with a per-item adjustment action" do
          let(:order) { create(:order_with_line_items, line_items_count: 3, store: store) }

          context "right coupon given" do
            context "with correct coupon code casing" do
              before { allow(order).to receive_messages coupon_code: "10off" }

              it "successfully activates promo" do
                expect(order.total).to eq(130)
                subject.apply
                expect(subject.success).to be_present
                order.line_items.each do |line_item|
                  expect(line_item.adjustments.count).to eq(1)
                end
                # Ensure that applying the adjustment actually affects the order's total!
                expect(order.reload.total).to eq(100)
              end

              it "coupon already applied to the order" do
                subject.apply
                expect(subject.success).to be_present
                subject.apply
                expect(subject.error).to eq I18n.t(:coupon_code_already_applied, scope: :aypex)
              end
            end

            # Regression test for #4211
            context "with incorrect coupon code casing" do
              before { allow(order).to receive_messages coupon_code: "10OFF" }

              it "successfully activates promo" do
                expect(order.total).to eq(130)
                subject.apply
                expect(subject.success).to be_present
                order.line_items.each do |line_item|
                  expect(line_item.adjustments.count).to eq(1)
                end
                # Ensure that applying the adjustment actually affects the order's total!
                expect(order.reload.total).to eq(100)
              end
            end
          end

          context "coexists with a non coupon code promo" do
            let!(:order) { create(:order, store: store) }

            before do
              allow(order).to receive_messages coupon_code: "10off"
              calculator = Calculator::Promotion::FlatRate.new(amount: 10)
              general_promo = create(:promotion, name: "General Promo", stores: [order.store])
              Promotion::Actions::CreateItemAdjustments.create(promotion: general_promo, calculator: calculator) # general_action

              Aypex::Cart::AddItem.call(order: order, variant: create(:variant))
            end

            # regression spec for #4515
            it "successfully activates promo" do
              subject.apply
              expect(subject).to be_successful
            end
          end
        end

        context "with a free-shipping adjustment action" do
          let!(:action) { Promotion::Actions::FreeShipping.create(promotion: promotion) }

          context "right coupon code given" do
            let(:order) { create(:order_with_line_items, line_items_count: 3, store: store) }

            before { allow(order).to receive_messages coupon_code: "10off" }

            it "successfully activates promo" do
              expect(order.total).to eq(130)
              subject.apply
              expect(subject.success).to be_present

              expect(order.shipment_adjustments.count).to eq(1)
            end

            it "coupon already applied to the order" do
              subject.apply
              expect(subject.success).to be_present
              subject.apply
              expect(subject.error).to eq I18n.t(:coupon_code_already_applied, scope: :aypex)
            end
          end
        end

        context "for an order with taxable line items" do
          let!(:order) { create(:order, line_items_price: 0.0, store: store) }
          let!(:zone) { create(:zone_with_country, default_tax: true) }
          let!(:tax_category) { create(:tax_category, name: "Taxable Foo") }
          let!(:rate) { create(:tax_rate, amount: 0.10, tax_category: tax_category, zone: zone) }

          before { allow(order).to receive(:coupon_code).and_return "10off" }

          context "and the product price is less than promo discount" do
            let(:product_list) { create_list(:product, 3, tax_category: tax_category, price: 9.0, stores: [store]) }

            before { product_list.each { |item| Aypex::Cart::AddItem.call(order: order, variant: item.master) } }

            it "successfully applies the promo" do
              # 3 * (9 + 0.9)
              expect(order.total).to eq(29.7)
              subject.apply
              expect(subject.success).to be_present
              # 3 * ((9 - [9,10].min) + 0)
              expect(order.reload.total).to eq(0)
              expect(order.additional_tax_total).to eq(0)
            end
          end

          context "and the product price is greater than promo discount" do
            let(:product_list) { create_list(:product, 3, tax_category: tax_category, price: 11.0, stores: [store]) }

            before { product_list.each { |item| Aypex::Cart::AddItem.call(order: order, variant: item.master, quantity: 2) } }

            it "successfully applies the promo" do
              # 3 * (22 + 2.2)
              expect(order.total.to_f).to eq(72.6)
              subject.apply
              expect(subject.success).to be_present
              # 3 * ( (22 - 10) + 1.2)
              expect(order.reload.total).to eq(39.6)
              expect(order.additional_tax_total).to eq(3.6)
            end
          end

          context "and multiple quantity per line item" do
            let(:promotion) { create(:promotion, :with_line_item_adjustment, adjustment_rate: 20, code: "20off", stores: [store]) }
            let(:product_list) { create_list(:product, 3, tax_category: tax_category, price: 10.0, stores: [store]) }

            before do
              allow(order).to receive(:coupon_code).and_return "20off"
              product_list.each { |item| Aypex::Cart::AddItem.call(order: order, variant: item.master, quantity: 2) }
            end

            it "successfully applies the promo" do
              # 3 * ((2 * 10) + 2.0)
              expect(order.total.to_f).to eq(66)
              subject.apply
              expect(subject.success).to be_present
              # 0
              expect(order.reload.total).to eq(0)
              expect(order.additional_tax_total).to eq(0)
            end
          end
        end

        context "with a CreateLineItems action" do
          let!(:variant) { create(:variant) }
          let!(:action) { Promotion::Actions::CreateLineItems.create(promotion: promotion) }
          let(:order) { create(:order, store: store) }

          before do
            action.promotion_action_line_items.create(
              variant: variant,
              quantity: 1
            )
            allow(order).to receive_messages(coupon_code: "10off")
          end

          it "successfully activates promo" do
            subject.apply
            expect(subject.success).to be_present
            expect(order.line_items.pluck(:variant_id)).to include(variant.id)
          end
        end
      end
    end
  end
end
