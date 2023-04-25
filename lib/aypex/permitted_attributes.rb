module Aypex
  module PermittedAttributes
    ATTRIBUTES = [
      :address_attributes,
      :checkout_attributes,
      :classification_attributes,
      :cms_page_attributes,
      :cms_section_attributes,
      :customer_return_attributes,
      :digital_attributes,
      :digital_link_attributes,
      :image_attributes,
      :inventory_unit_attributes,
      :line_item_attributes,
      :menu_attributes,
      :menu_item_attributes,
      :option_type_attributes,
      :option_value_attributes,
      :payment_attributes,
      :product_attributes,
      :product_properties_attributes,
      :property_attributes,
      :return_authorization_attributes,
      :shipment_attributes,
      :source_attributes,
      :stock_item_attributes,
      :stock_location_attributes,
      :stock_movement_attributes,
      :store_attributes,
      :store_credit_attributes,
      :category_attributes,
      :base_category_attributes,
      :user_attributes,
      :variant_attributes,
      :wishlist_attributes,
      :wished_item_attributes
    ]

    mattr_reader(*ATTRIBUTES)

    @@address_attributes = [
      :id, :firstname, :lastname, :first_name, :last_name,
      :address1, :address2, :city, :country_iso, :country_id, :state_id,
      :zipcode, :phone, :state_name, :alternative_phone, :company,
      :user_id, :deleted_at, :label,
      {country: [:iso, :name, :iso3, :iso_name],
       state: [:name, :abbr]}
    ]

    @@checkout_attributes = [
      :coupon_code, :email, :shipping_method_id, :special_instructions, :use_billing,
      :use_shipping, :user_id, :bill_address_id, :ship_address_id
    ]

    @@classification_attributes = [
      :position, :category_id, :product_id
    ]

    @@cms_page_attributes = [:title, :meta_title, :content, :meta_description, :visible, :slug, :locale]

    @@cms_section_attributes = [:name, :cms_page_id, :fit, :destination, {content: {}, settings: {}}]

    @@customer_return_attributes = [:stock_location_id, {
      return_items_attributes: [:id, :inventory_unit_id, :return_authorization_id, :returned, :pre_tax_amount,
        :acceptance_status, :exchange_variant_id, :resellable]
    }]

    @@digital_attributes = [:attachment, :variant_id]

    @@digital_link_attributes = [:access_counter]

    @@image_attributes = [:alt, :attachment, :position, :viewable_type, :viewable_id]

    @@inventory_unit_attributes = [:shipment, :shipment_id, :variant_id]

    @@line_item_attributes = [:id, :variant_id, :quantity]

    @@menu_attributes = [:name, :locale, :location]

    @@menu_item_attributes = [:name, :subtite, :destination, :new_window, :item_type,
      :linked_resource_type, :linked_resource_id, :code, :menu_id]

    @@option_type_attributes = [:name, :presentation, :option_values_attributes]

    @@option_value_attributes = [:name, :presentation]

    @@payment_attributes = [:amount, :payment_method_id, :payment_method]

    @@product_properties_attributes = [:property_name, :value, :position]

    @@product_attributes = [
      :name, :description, :available_on, :make_active_at, :discontinue_on, :permalink, :meta_description,
      :meta_keywords, :price, :sku, :deleted_at, :prototype_id,
      :option_values_hash, :weight, :height, :width, :depth,
      :shipping_category_id, :tax_category_id,
      :cost_currency, :cost_price, :compare_at_price,
      {option_type_ids: [], category_ids: []}
    ]

    @@property_attributes = [:name, :presentation]

    @@return_authorization_attributes = [:amount, :memo, :stock_location_id, :inventory_units_attributes,
      :return_authorization_reason_id]

    @@shipment_attributes = [
      :order, :special_instructions, :stock_location_id, :id,
      :tracking, :address, :inventory_units, :selected_shipping_rate_id
    ]

    # month / year may be provided by some sources, or others may elect to use one field
    @@source_attributes = [
      :number, :month, :year, :expiry, :verification_value,
      :first_name, :last_name, :cc_type, :gateway_customer_profile_id,
      :gateway_payment_profile_id, :last_digits, :name, :encrypted_data
    ]

    @@stock_item_attributes = [:variant, :stock_location, :backorderable, :variant_id]

    @@stock_location_attributes = [
      :name, :active, :address1, :address2, :city, :zipcode,
      :backorderable_default, :state_name, :state_id, :country_id, :phone,
      :propagate_all_variants
    ]

    @@stock_movement_attributes = [
      :quantity, :stock_item, :stock_item_id, :originator, :action
    ]

    @@store_attributes = [:name, :url, :seo_title, :code, :meta_keywords,
      :meta_description, :default_currency, :mail_from_address,
      :customer_support_email, :facebook, :twitter, :instagram,
      :description, :address, :contact_phone, :supported_locales,
      :default_locale, :default_country_id, :supported_currencies,
      :new_order_notifications_email, :checkout_zone_id, :seo_robots,
      :digital_asset_authorized_clicks, :digital_asset_authorized_days,
      :limit_digital_download_count, :limit_digital_download_days, :digital_asset_link_expire_time,
      {mailer_logo_attributes: {}, favicon_image_attributes: {}, logo_attributes: {}}]

    @@store_credit_attributes = %i[amount currency category_id memo]

    @@base_category_attributes = [:name]

    @@category_attributes = [
      :name, :parent_id, :position, :image, :description, :permalink, :hide_from_nav,
      :base_category_id, :meta_description, :meta_keywords, :meta_title, :child_index
    ]

    # TODO: Should probably use something like Aypex::Config.user_class.attributes
    @@user_attributes = [:email, :bill_address_id, :ship_address_id, :password, :first_name, :last_name,
      :password_confirmation, :store_id, {public_metadata: {}, private_metadata: {}}, :selected_locale]

    @@variant_attributes = [
      :name, :presentation, :cost_price, :discontinue_on, :lock_version,
      :position, :track_inventory,
      :product_id, :product, :option_values_attributes, :price, :compare_at_price,
      :weight, :height, :width, :depth, :sku, :barcode, :cost_currency,
      {options: [:name, :value], option_value_ids: []}
    ]

    @@wishlist_attributes = [:name, :is_default, :is_private]

    @@wished_item_attributes = [:variant_id, :quantity]
  end
end
