module Aypex
  module PromotionHandler
    class Coupon
      attr_reader :order, :store
      attr_accessor :error, :success, :status_code

      def initialize(order)
        @order = order
        @store = order.store
      end

      def apply
        if order.coupon_code.present?
          if promotion.present? && promotion.actions.exists?
            handle_present_promotion
          elsif store.promotions.with_coupon_code(order.coupon_code).try(:expired?)
            set_error_code :coupon_code_expired  # i18n-tasks-use I18n.t("aypex.coupon_code_expired")
          else
            set_error_code :coupon_code_not_found # i18n-tasks-use I18n.t("aypex.coupon_code_not_found")
          end
        else
          set_error_code :coupon_code_not_found # i18n-tasks-use I18n.t("aypex.coupon_code_not_found")
        end
        self
      end

      def remove(coupon_code)
        promotion = order.promotions.with_coupon_code(coupon_code)
        if promotion.present?
          # Order promotion has to be destroyed before line item removing
          order.order_promotions.where(promotion_id: promotion.id).destroy_all

          remove_promotion_adjustments(promotion)
          remove_promotion_line_items(promotion)
          order.update_with_updater!

          set_success_code :adjustments_deleted # i18n-tasks-use I18n.t("aypex.adjustments_deleted")
        else
          set_error_code :coupon_code_not_found # i18n-tasks-use I18n.t("aypex.coupon_code_not_found")
        end
        self
      end

      def set_success_code(code)
        @status_code = code
        @success = I18n.t(code, scope: :aypex)
      end

      def set_error_code(code)
        @status_code = code
        @error = I18n.t(code, scope: :aypex)
      end

      def promotion
        @promotion ||= store.promotions.active.includes(
          :promotion_rules, :promotion_actions
        ).with_coupon_code(order.coupon_code)
      end

      def successful?
        success.present? && error.blank?
      end

      private

      def remove_promotion_adjustments(promotion)
        promotion_actions_ids = promotion.actions.pluck(:id)
        order.all_adjustments.where(source_id: promotion_actions_ids,
          source_type: "Aypex::PromotionAction").destroy_all
      end

      def remove_promotion_line_items(promotion)
        create_line_item_actions_ids = promotion.actions.where(type: "Aypex::Promotion::Actions::CreateLineItems").pluck(:id)

        Aypex::PromotionActionLineItem.where(promotion_action: create_line_item_actions_ids).find_each do |item|
          line_item = order.find_line_item_by_variant(item.variant)
          next if line_item.blank?

          Aypex::Dependency.cart_remove_item_service.constantize.call(order: order, variant: item.variant, quantity: item.quantity)
        end
      end

      def handle_present_promotion
        return promotion_usage_limit_exceeded if promotion.usage_limit_exceeded?(order)
        return promotion_applied if promotion_exists_on_order?

        unless promotion.eligible?(order)
          self.error = promotion.eligibility_errors.full_messages.first unless promotion.eligibility_errors.blank?
          return (error || ineligible_for_this_order)
        end

        # If any of the actions for the promotion return `true`,
        # then result here will also be `true`.
        if promotion.activate(order: order)
          determine_promotion_application_result
        else
          set_error_code :coupon_code_unknown_error # i18n-tasks-use I18n.t("aypex.coupon_code_unknown_error")
        end
      end

      def promotion_usage_limit_exceeded
        set_error_code :coupon_code_max_usage # i18n-tasks-use I18n.t("aypex.coupon_code_max_usage")
      end

      def ineligible_for_this_order
        set_error_code :coupon_code_not_eligible # i18n-tasks-use I18n.t("aypex.coupon_code_not_eligible")
      end

      def promotion_applied
        set_error_code :coupon_code_already_applied # i18n-tasks-use I18n.t("aypex.coupon_code_already_applied")
      end

      def promotion_exists_on_order?
        order.promotions.include? promotion
      end

      def determine_promotion_application_result
        # Check for applied adjustments.
        discount = order.all_adjustments.promotion.eligible.detect do |p|
          p.source.promotion.code.try(:downcase) == order.coupon_code.downcase
        end

        # Check for applied line items.
        created_line_items = promotion.actions.detect do |a|
          Object.const_get(a.type).ancestors.include?(
            Aypex::Promotion::Actions::CreateLineItems
          )
        end

        if discount || created_line_items
          order.update_totals
          order.persist_totals
          set_success_code :coupon_code_applied # i18n-tasks-use I18n.t("aypex.coupon_code_applied")
        elsif order.promotions.with_coupon_code(order.coupon_code)
          # if the promotion exists on an order, but wasn't found above,
          # we've already selected a better promotion
          set_error_code :coupon_code_better_exists # i18n-tasks-use I18n.t("aypex.coupon_code_better_exists")
        else
          # if the promotion was created after the order
          set_error_code :coupon_code_not_found # i18n-tasks-use I18n.t("aypex.coupon_code_not_found")
        end
      end
    end
  end
end
