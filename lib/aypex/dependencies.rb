require_relative "dependencies_helper"

module Aypex
  class Dependencies
    include Aypex::DependenciesHelper

    INJECTION_POINTS = [
      :ability_class,
      :cart_create_service, :cart_add_item_service, :cart_remove_item_service,
      :cart_remove_line_item_service, :cart_set_item_quantity_service, :cart_recalculate_service,
      :cms_page_finder, :cart_update_service, :checkout_next_service, :checkout_advance_service, :checkout_update_service,
      :checkout_complete_service, :checkout_add_store_credit_service, :checkout_remove_store_credit_service, :checkout_get_shipping_rates_service,
      :coupon_handler, :menu_finder, :country_finder, :current_order_finder, :credit_card_finder,
      :completed_order_finder, :order_sorter, :cart_compare_line_items_service, :collection_paginator, :products_sorter,
      :products_finder, :taxon_finder, :line_item_by_variant_finder, :cart_estimate_shipping_rates_service,
      :account_create_address_service, :account_update_address_service, :account_create_service, :account_update_service,
      :address_finder, :collection_sorter, :error_handler, :current_store_finder, :cart_empty_service, :cart_destroy_service,
      :classification_reposition_service, :credit_cards_destroy_service, :cart_associate_service, :cart_change_currency_service,
      :line_item_create_service, :line_item_update_service, :line_item_destroy_service,
      :order_approve_service, :order_cancel_service, :shipment_change_state_service, :shipment_update_service,
      :shipment_create_service, :shipment_add_item_service, :shipment_remove_item_service,
      :payment_create_service, :address_create_service, :address_update_service,
      :checkout_select_shipping_method_service
    ].freeze

    attr_accessor(*INJECTION_POINTS)

    def initialize
      set_default_ability
      set_default_services
      set_default_finders
    end

    private

    def set_default_ability
      @ability_class = "Aypex::Ability"
    end

    def set_default_services
      # cart
      @cart_compare_line_items_service = "Aypex::CompareLineItems"
      @cart_create_service = "Aypex::Cart::Create"
      @cart_add_item_service = "Aypex::Cart::AddItem"
      @cart_update_service = "Aypex::Cart::Update"
      @cart_recalculate_service = "Aypex::Cart::Recalculate"
      @cart_remove_item_service = "Aypex::Cart::RemoveItem"
      @cart_remove_line_item_service = "Aypex::Cart::RemoveLineItem"
      @cart_set_item_quantity_service = "Aypex::Cart::SetQuantity"
      @cart_estimate_shipping_rates_service = "Aypex::Cart::EstimateShippingRates"
      @cart_empty_service = "Aypex::Cart::Empty"
      @cart_destroy_service = "Aypex::Cart::Destroy"
      @cart_associate_service = "Aypex::Cart::Associate"
      @cart_change_currency_service = "Aypex::Cart::ChangeCurrency"

      # checkout
      @checkout_next_service = "Aypex::Checkout::Next"
      @checkout_advance_service = "Aypex::Checkout::Advance"
      @checkout_update_service = "Aypex::Checkout::Update"
      @checkout_complete_service = "Aypex::Checkout::Complete"
      @checkout_add_store_credit_service = "Aypex::Checkout::AddStoreCredit"
      @checkout_remove_store_credit_service = "Aypex::Checkout::RemoveStoreCredit"
      @checkout_get_shipping_rates_service = "Aypex::Checkout::GetShippingRates"
      @checkout_select_shipping_method_service = "Aypex::Checkout::SelectShippingMethod"

      # order
      @order_approve_service = "Aypex::Orders::Approve"
      @order_cancel_service = "Aypex::Orders::Cancel"

      # shipment
      @shipment_change_state_service = "Aypex::Shipments::ChangeState"
      @shipment_create_service = "Aypex::Shipments::Create"
      @shipment_update_service = "Aypex::Shipments::Update"
      @shipment_add_item_service = "Aypex::Shipments::AddItem"
      @shipment_remove_item_service = "Aypex::Shipments::RemoveItem"

      # sorter
      @collection_sorter = "Aypex::BaseSorter"
      @order_sorter = "Aypex::BaseSorter"
      @products_sorter = "Aypex::Products::Sort"

      # paginator
      @collection_paginator = "Aypex::Shared::Paginate"

      # coupons
      # TODO: we should split this service into 2 separate - Add and Remove
      @coupon_handler = "Aypex::PromotionHandler::Coupon"

      # account
      @account_create_service = "Aypex::Account::Create"
      @account_update_service = "Aypex::Account::Update"

      # addresses
      @address_create_service = "Aypex::Addresses::Create"
      @address_update_service = "Aypex::Addresses::Update"

      # credit cards
      @credit_cards_destroy_service = "Aypex::CreditCards::Destroy"

      # classifications
      @classification_reposition_service = "Aypex::Classifications::Reposition"

      # line items
      @line_item_create_service = "Aypex::LineItems::Create"
      @line_item_update_service = "Aypex::LineItems::Update"
      @line_item_destroy_service = "Aypex::LineItems::Destroy"

      @payment_create_service = "Aypex::Payments::Create"

      # errors
      @error_handler = "Aypex::ErrorReporter"
    end

    def set_default_finders
      @address_finder = "Aypex::Addresses::Find"
      @country_finder = "Aypex::Countries::Find"
      @cms_page_finder = "Aypex::CmsPages::Find"
      @menu_finder = "Aypex::Menus::Find"
      @current_order_finder = "Aypex::Orders::FindCurrent"
      @current_store_finder = "Aypex::Stores::FindCurrent"
      @completed_order_finder = "Aypex::Orders::FindComplete"
      @credit_card_finder = "Aypex::CreditCards::Find"
      @products_finder = "Aypex::Products::Find"
      @taxon_finder = "Aypex::Taxons::Find"
      @line_item_by_variant_finder = "Aypex::LineItems::FindByVariant"
    end
  end
end
