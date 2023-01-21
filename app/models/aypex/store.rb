module Aypex
  class Store < Aypex::Base
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)
    include Aypex::Security::Stores if defined?(Aypex::Security::Stores)

    typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
      s.boolean :address_require_phone_number, default: false, null: false
      s.boolean :address_require_alt_phone_number, default: false, null: false
      s.boolean :address_show_company_address_field, default: false, null: false

      s.boolean :checkout_allow_guest_checkout, default: true, null: false
      s.boolean :checkout_alternative_shipping_phone, default: true, null: false
      s.boolean :checkout_shipping_instructions, default: false, null: false
      s.boolean :checkout_always_include_confirm_step, default: false, null: false

      s.boolean :show_variant_full_price, default: false, null: false
      s.boolean :tax_using_ship_address, default: true, null: false
      s.boolean :use_the_user_preferred_locale, default: true, null: false

      s.integer :digital_asset_authorized_clicks, default: 5, null: false # number of times a customer can download a digital file.
      s.integer :digital_asset_authorized_days, default: 7, null: false # number of days after initial purchase the customer can download a file.
      s.integer :digital_asset_link_expire_time, default: 300, null: false # 5 minutes in seconds
      s.boolean :limit_digital_download_count, default: true, null: false
      s.boolean :limit_digital_download_days, default: true, null: false

      s.integer :return_eligibility_number_of_days, default: 365, null: false # days after purchase customer can return.
    end

    attr_accessor :skip_validate_not_last

    acts_as_paranoid

    has_many :orders, class_name: "Aypex::Order"
    has_many :line_items, through: :orders, class_name: "Aypex::LineItem"
    has_many :shipments, through: :orders, class_name: "Aypex::Shipment"
    has_many :payments, through: :orders, class_name: "Aypex::Payment"
    has_many :return_authorizations, through: :orders, class_name: "Aypex::ReturnAuthorization"
    # has_many :reimbursements, through: :orders, class_name: 'Aypex::Reimbursement' FIXME: we should fetch this via Customer Return

    has_many :store_payment_methods, class_name: "Aypex::StorePaymentMethod"
    has_many :payment_methods, through: :store_payment_methods, class_name: "Aypex::PaymentMethod"

    has_many :cms_pages, class_name: "Aypex::CmsPage"
    has_many :cms_sections, through: :cms_pages, class_name: "Aypex::CmsSection"

    has_many :menus, class_name: "Aypex::Menu"
    has_many :menu_items, through: :menus, class_name: "Aypex::MenuItem"

    has_many :store_products, class_name: "Aypex::StoreProduct"
    has_many :products, through: :store_products, class_name: "Aypex::Product"
    has_many :product_properties, through: :products, class_name: "Aypex::ProductProperty"
    has_many :variants, through: :products, class_name: "Aypex::Variant", source: :variants_including_master
    has_many :stock_items, through: :variants, class_name: "Aypex::StockItem"
    has_many :inventory_units, through: :variants, class_name: "Aypex::InventoryUnit"
    has_many :customer_returns, class_name: "Aypex::CustomerReturn", inverse_of: :store

    has_many :store_credits, class_name: "Aypex::StoreCredit"
    has_many :store_credit_events, through: :store_credits, class_name: "Aypex::StoreCreditEvent"

    has_many :base_categories, class_name: "Aypex::BaseCategory"
    has_many :categories, through: :base_categories, class_name: "Aypex::Category"

    has_many :store_promotions, class_name: "Aypex::StorePromotion"
    has_many :promotions, through: :store_promotions, class_name: "Aypex::Promotion"

    has_many :wishlists, class_name: "Aypex::Wishlist"

    belongs_to :default_country, class_name: "Aypex::Country"
    belongs_to :checkout_zone, class_name: "Aypex::Zone"

    with_options presence: true do
      validates :name, :url, :mail_from_address, :default_currency, :code
    end

    validates :digital_asset_authorized_clicks, numericality: {only_integer: true, greater_than: 0}
    validates :digital_asset_authorized_days, numericality: {only_integer: true, greater_than: 0}
    validates :code, uniqueness: {case_sensitive: false, conditions: -> { with_deleted }}
    validates :mail_from_address, email: {allow_blank: false}

    # FIXME: we should remove this condition in v5
    if !ENV["AYPEX_DISABLE_DB_CONNECTION"] &&
        connected? &&
        table_exists? &&
        connection.column_exists?(:aypex_stores, :new_order_notifications_email)
      validates :new_order_notifications_email, email: {allow_blank: true}
    end

    default_scope { order(created_at: :asc) }

    has_one :logo, class_name: "Aypex::StoreLogo", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :logo, reject_if: :all_blank

    has_one :mailer_logo, class_name: "Aypex::StoreMailerLogo", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :mailer_logo, reject_if: :all_blank

    has_one :favicon_image, class_name: "Aypex::StoreFaviconImage", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :favicon_image, reject_if: :all_blank

    before_save :ensure_default_exists_and_is_unique
    before_save :ensure_supported_currencies, :ensure_supported_locales, :ensure_default_country
    before_destroy :validate_not_last, unless: :skip_validate_not_last
    before_destroy :pass_default_flag_to_other_store

    scope :by_url, ->(url) { where("url like ?", "%#{url}%") }

    after_commit :clear_cache

    alias_attribute :contact_email, :customer_support_email

    # FIXME: we need to drop `or_initialize` in v5
    # this behavior is very buggy and unpredictable
    def self.default
      Rails.cache.fetch("default_store") do
        where(default: true).first_or_initialize
      end
    end

    def self.available_locales
      Rails.cache.fetch("stores_available_locales") do
        Aypex::Store.all.map(&:supported_locales_list).flatten.uniq
      end
    end

    def default_menu(location)
      menu = menus.find_by(location: location, locale: default_locale) || menus.find_by(location: location)

      menu.root if menu.present?
    end

    def supported_currencies_list
      @supported_currencies_list ||= (read_attribute(:supported_currencies).to_s.split(",") << default_currency).sort.map(&:to_s).map do |code|
        ::Money::Currency.find(code.strip)
      end.uniq.compact
    end

    def homepage(requested_locale)
      cms_pages.by_locale(requested_locale).find_by(type: "Aypex::Cms::Pages::Homepage") ||
        cms_pages.by_locale(default_locale).find_by(type: "Aypex::Cms::Pages::Homepage") ||
        cms_pages.find_by(type: "Aypex::Cms::Pages::Homepage")
    end

    def seo_meta_description
      if meta_description.present?
        meta_description
      elsif seo_title.present?
        seo_title
      else
        name
      end
    end

    def supported_locales_list
      # TODO: add support of multiple supported languages to a single Store
      @supported_locales_list ||= (read_attribute(:supported_locales).to_s.split(",") << default_locale).compact.uniq.sort
    end

    def unique_name
      @unique_name ||= "#{name} (#{code})"
    end

    def formatted_url
      return if url.blank?

      @formatted_url ||= if /http:\/\/|https:\/\//.match?(url)
        url
      else
        (Rails.env.development? || Rails.env.test?) ? "http://#{url}" : "https://#{url}"
      end
    end

    def countries_available_for_checkout
      @countries_available_for_checkout ||= checkout_zone.try(:country_list) || Aypex::Country.all
    end

    def states_available_for_checkout(country)
      checkout_zone.try(:state_list_for, country) || country.states
    end

    def checkout_zone_or_default
      ActiveSupport::Deprecation.warn("Store#checkout_zone_or_default is deprecated and will be removed in Aypex 5")

      @checkout_zone_or_default ||= checkout_zone || Aypex::Zone.default_checkout_zone
    end

    def favicon
      return unless favicon_image&.attachment&.attached?

      favicon_image.attachment.variant(resize_to_limit: [32, 32])
    end

    def can_be_deleted?
      self.class.where.not(id: id).any?
    end

    private

    def ensure_default_exists_and_is_unique
      if default
        Store.where.not(id: id).update_all(default: false)
      elsif Store.where(default: true).count.zero?
        self.default = true
      end
    end

    def ensure_supported_locales
      return unless attributes.key?("supported_locales")
      return if supported_locales.present?
      return if default_locale.blank?

      self.supported_locales = default_locale
    end

    def ensure_supported_currencies
      return unless attributes.key?("supported_currencies")
      return if supported_currencies.present?
      return if default_currency.blank?

      self.supported_currencies = default_currency
    end

    def validate_not_last
      unless can_be_deleted?
        errors.add(:base, :cannot_destroy_only_store)
        throw(:abort)
      end
    end

    def pass_default_flag_to_other_store
      if default? && can_be_deleted?
        self.class.where.not(id: id).first.update!(default: true)
        self.default = false
      end
    end

    def clear_cache
      Rails.cache.delete("default_store")
      Rails.cache.delete("stores_available_locales")
    end

    def ensure_default_country
      return unless has_attribute?(:default_country_id)
      return if default_country.present? && (checkout_zone.blank? || checkout_zone.country_list.blank? || checkout_zone.country_list.include?(default_country))

      self.default_country = if checkout_zone.present? && checkout_zone.country_list.any?
        checkout_zone.country_list.first
      else
        Country.find_by(iso: "US") || Country.first
      end
    end
  end
end
