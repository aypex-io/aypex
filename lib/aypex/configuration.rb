require "aypex/search/base"

module Aypex
  class Configuration
    attr_writer :address_requires_phone, :allow_checkout_on_gateway_error, :auto_capture,
      :auto_capture_on_dispatch, :binary_inventory_cache, :credit_to_new_allocation,
      :disable_sku_validation, :disable_store_presence_validation, :expedited_exchanges,
      :expedited_exchanges_days_window, :non_expiring_credit_types, :products_per_page,
      :restock_inventory, :require_master_price, :send_core_emails, :track_inventory_levels,
      :show_products_without_price, :storefront_products_path, :storefront_categories_path,
      :storefront_pages_path, :searcher_class, :public_storage_service_name, :private_storage_service_name,
      :user_class, :admin_user_class, :cdn_host

    def cdn_host
      @cdn_host
    end

    def user_class(constantize: true)
      if @user_class.is_a?(Class)
        raise "Aypex::Config.user_class MUST be a String or Symbol object, not a Class object."
      elsif @user_class.is_a?(String) || @user_class.is_a?(Symbol)
        constantize ? @user_class.to_s.constantize : @user_class.to_s
      end
    end

    def admin_user_class(constantize: true)
      @admin_user_class ||= @user_class

      if @admin_user_class.is_a?(Class)
        raise "Aypex::Config.admin_user_class MUST be a String or Symbol object, not a Class object."
      elsif @admin_user_class.is_a?(String) || @admin_user_class.is_a?(Symbol)
        constantize ? @admin_user_class.to_s.constantize : @admin_user_class.to_s
      end
    end

    def searcher_class(constantize: true)
      @searcher_class ||= "Aypex::Search::Base"

      if @searcher_class.is_a?(Class)
        raise "Aypex::Config.searcher_class MUST be a String or Symbol object, not a Class object."
      elsif @searcher_class.is_a?(String) || @searcher_class.is_a?(Symbol)
        constantize ? @searcher_class.to_s.constantize : @searcher_class.to_s
      end
    end

    def private_storage_service_name
      if @private_storage_service_name
        if @private_storage_service_name.is_a?(String) || @private_storage_service_name.is_a?(Symbol)
          @private_storage_service_name.to_sym
        else
          raise "Aypex::Config.private_storage_service_name MUST be a String or Symbol object."
        end
      end
    end

    def public_storage_service_name
      if @public_storage_service_name
        if @public_storage_service_name.is_a?(String) || @public_storage_service_name.is_a?(Symbol)
          @public_storage_service_name.to_sym
        else
          raise "Aypex::Config.public_storage_service_name MUST be a String or Symbol object."
        end
      end
    end

    # address_requires_phone
    # Determines whether we require phone number in address
    def address_requires_phone # This could be a per store setting.
      self.address_requires_phone = true unless @address_requires_phone == false

      if @address_requires_phone.in? [true, false]
        @address_requires_phone
      else
        raise "Aypex::Config.address_requires_phone MUST be a Boolean (true / false)"
      end
    end

    # Why?
    def allow_checkout_on_gateway_error
      self.allow_checkout_on_gateway_error = false unless @allow_checkout_on_gateway_error == true

      if @allow_checkout_on_gateway_error.in? [true, false]
        @allow_checkout_on_gateway_error
      else
        raise "Aypex::Config.allow_checkout_on_gateway_error MUST be a Boolean (true / false)"
      end
    end

    # automatically capture the credit card (as opposed to just authorize and capture later)
    def auto_capture # This should be a per-checkout option
      self.auto_capture = false unless @auto_capture == true

      if @auto_capture.in? [true, false]
        @auto_capture
      else
        raise "Aypex::Config.auto_capture MUST be a Boolean (true / false)"
      end
    end

    # Captures payment for each shipment in Shipment#after_ship callback, and makes Shipment.ready when payment authorized.
    def auto_capture_on_dispatch # This could be a per store setting.
      self.auto_capture_on_dispatch = false unless @auto_capture_on_dispatch == true

      if @auto_capture_on_dispatch.in? [true, false]
        @auto_capture_on_dispatch
      else
        raise "Aypex::Config.auto_capture_on_dispatch MUST be a Boolean (true / false)"
      end
    end

    # only invalidate product cache when a stock item changes whether it is in_stock
    def binary_inventory_cache
      self.binary_inventory_cache = false unless @binary_inventory_cache == true

      if @binary_inventory_cache.in? [true, false]
        @binary_inventory_cache
      else
        raise "Aypex::Config.binary_inventory_cache MUST be a Boolean (true / false)"
      end
    end

    def credit_to_new_allocation
      self.credit_to_new_allocation = false unless @credit_to_new_allocation == true

      if @credit_to_new_allocation.in? [true, false]
        @credit_to_new_allocation
      else
        raise "Aypex::Config.credit_to_new_allocation MUST be a Boolean (true / false)"
      end
    end

    # when turned off disables Store presence validation for Products and Payment Methods
    def disable_store_presence_validation
      self.disable_store_presence_validation = false unless @disable_store_presence_validation == true

      if @disable_store_presence_validation.in? [true, false]
        @disable_store_presence_validation
      else
        raise "Aypex::Config.disable_store_presence_validation MUST be a Boolean (true / false)"
      end
    end

    # when turned off disables the built-in SKU uniqueness validation
    def disable_sku_validation
      self.disable_sku_validation = false unless @disable_sku_validation == true

      if @disable_sku_validation.in? [true, false]
        @disable_sku_validation
      else
        raise "Aypex::Config.disable_sku_validation MUST be a Boolean (true / false)"
      end
    end

    # only invalidate product cache when a stock item changes whether it is in_stock
    def expedited_exchanges
      self.expedited_exchanges = false unless @expedited_exchanges == true

      if @expedited_exchanges.in? [true, false]
        @expedited_exchanges
      else
        raise "Aypex::Config.expedited_exchanges MUST be a Boolean (true / false)"
      end
    end

    # expedited_exchanges_days_window
    #
    # The amount of days the customer has to return their item after the expedited
    # exchange is shipped in order to avoid being charged.
    def expedited_exchanges_days_window # This could be a per store setting.
      self.expedited_exchanges_days_window = 14 unless @expedited_exchanges_days_window

      if @expedited_exchanges_days_window.is_a?(Integer)
        @expedited_exchanges_days_window
      else
        raise "Aypex::Config.expedited_exchanges_days_window MUST be an Integer"
      end
    end

    # non_expiring_credit_types
    def non_expiring_credit_types
      self.non_expiring_credit_types = [] unless @non_expiring_credit_types

      if @non_expiring_credit_types.is_a?(Array)
        @non_expiring_credit_types
      else
        raise "Aypex::Config.non_expiring_credit_types MUST be an Array"
      end
    end

    # products_per_page
    #
    # Required for search.
    def products_per_page
      self.products_per_page = 12 unless @products_per_page

      if @products_per_page.is_a?(Integer)
        @products_per_page
      else
        raise "Aypex::Config.products_per_page MUST be an Integer"
      end
    end

    def require_master_price
      self.require_master_price = true unless @require_master_price == false

      if @require_master_price.in? [true, false]
        @require_master_price
      else
        raise "Aypex::Config.require_master_price MUST be a Boolean (true / false)"
      end
    end

    # Default mail headers settings
    def send_core_emails
      self.send_core_emails = true unless @send_core_emails == false

      if @send_core_emails.in? [true, false]
        @send_core_emails
      else
        raise "Aypex::Config.send_core_emails MUST be a Boolean (true / false)"
      end
    end

    def show_products_without_price # This could be a per store setting.
      self.show_products_without_price = false unless @show_products_without_price == true

      if @show_products_without_price.in? [true, false]
        @show_products_without_price
      else
        raise "Aypex::Config.show_products_without_price MUST be a Boolean (true / false)"
      end
    end

    def storefront_products_path
      self.storefront_products_path = "products" unless @storefront_products_path

      if @storefront_products_path.is_a?(String)
        @storefront_products_path
      else
        raise "Aypex::Config.products_per_page MUST be an String"
      end
    end

    def storefront_categories_path
      self.storefront_categories_path = "t" unless @storefront_categories_path

      if @storefront_categories_path.is_a?(String)
        @storefront_categories_path
      else
        raise "Aypex::Config.storefront_categories_path MUST be an String"
      end
    end

    def storefront_pages_path
      self.storefront_pages_path = "pages" unless @storefront_pages_path

      if @storefront_pages_path.is_a?(String)
        @storefront_pages_path
      else
        raise "Aypex::Config.storefront_pages_path MUST be an String"
      end
    end

    # Determines if a return item is restocked automatically once it has been received
    def restock_inventory
      self.restock_inventory = true unless @restock_inventory == false

      if @restock_inventory.in? [true, false]
        @restock_inventory
      else
        raise "Aypex::Config.restock_inventory MUST be a Boolean (true / false)"
      end
    end

    def track_inventory_levels
      self.track_inventory_levels = true unless @track_inventory_levels == false

      if @track_inventory_levels.in? [true, false]
        @track_inventory_levels
      else
        raise "Aypex::Config.track_inventory_levels MUST be a Boolean (true / false)"
      end
    end
  end
end
