require "spec_helper"

RSpec.describe Aypex::Configuration do
  subject(:test_subject) { Aypex::Config }

  before { described_class.new }

  describe ".admin_user_class" do
    after { test_subject.admin_user_class = nil }

    context "when admin_user_class is nil" do
      it "fallback to user_class" do
        test_subject.user_class = "Aypex::LegacyUser"

        expect(test_subject.admin_user_class).to eq(Aypex::LegacyUser)
      end
    end

    context "when admin_user_class is a Class instance" do
      it "raises an error" do
        test_subject.admin_user_class = Aypex::LegacyUser

        expect { test_subject.admin_user_class }.to raise_error(RuntimeError)
      end
    end

    context "when admin_user_class is a Symbol instance" do
      it "returns the admin_user_class constant" do
        test_subject.admin_user_class = :"Aypex::LegacyUser"

        expect(test_subject.admin_user_class).to eq(Aypex::LegacyUser)
      end
    end

    context "when admin_user_class is a String instance" do
      it "returns the admin_user_class constant" do
        test_subject.admin_user_class = "Aypex::LegacyUser"

        expect(test_subject.admin_user_class).to eq(Aypex::LegacyUser)
      end
    end

    context "when constantize is false" do
      it "returns the admin_user_class as a String" do
        test_subject.admin_user_class = "Aypex::LegacyUser"

        expect(test_subject.admin_user_class(constantize: false)).to eq("Aypex::LegacyUser")
      end
    end
  end

  describe ".user_class" do
    after do
      test_subject.user_class = "Aypex::LegacyUser"
    end

    context "when user_class is a Class instance" do
      it "raises an error" do
        test_subject.user_class = Aypex::LegacyUser

        expect { test_subject.user_class }.to raise_error(RuntimeError)
      end
    end

    context "when user_class is a Symbol instance" do
      it "returns the user_class constant" do
        test_subject.user_class = :"Aypex::LegacyUser"

        expect(test_subject.user_class).to eq(Aypex::LegacyUser)
      end
    end

    context "when user_class is a String instance" do
      it "returns the user_class constant" do
        test_subject.user_class = "Aypex::LegacyUser"

        expect(test_subject.user_class).to eq(Aypex::LegacyUser)
      end
    end

    context "when constantize is false" do
      it "returns the user_class as a String" do
        test_subject.user_class = "Aypex::LegacyUser"

        expect(test_subject.user_class(constantize: false)).to eq("Aypex::LegacyUser")
      end
    end
  end

  describe ".searcher_class" do
    after { test_subject.searcher_class = "Aypex::Search::Base" }

    context "when searcher_class is a Class instance" do
      it "raises an error" do
        test_subject.searcher_class = Aypex::Search::Base

        expect { test_subject.searcher_class }.to raise_error(RuntimeError)
      end
    end

    context "when searcher_class is a Symbol instance" do
      it "returns the searcher_class constant" do
        test_subject.searcher_class = :"Aypex::Search::Base"

        expect(test_subject.searcher_class).to eq(Aypex::Search::Base)
      end
    end

    context "when searcher_class is a String instance" do
      it "returns the searcher_class constant" do
        test_subject.searcher_class = "Aypex::Search::Base"

        expect(test_subject.searcher_class).to eq(Aypex::Search::Base)
      end
    end

    context "when constantize is false" do
      it "returns the searcher_class as a String" do
        test_subject.searcher_class = "Aypex::Search::Base"

        expect(test_subject.searcher_class(constantize: false)).to eq("Aypex::Search::Base")
      end
    end
  end

  describe ".private_storage_service_name" do
    after { test_subject.private_storage_service_name = nil }

    context "when private_storage_service_name is a Symbol instance" do
      it "returns the private_storage_service_name as a symbol" do
        test_subject.private_storage_service_name = :my_secret_asset_store

        expect(test_subject.private_storage_service_name).to eq(:my_secret_asset_store)
      end
    end

    context "when private_storage_service_name is a String instance" do
      it "returns the private_storage_service_name as a symbol" do
        test_subject.private_storage_service_name = "my_hidden_asset_store"

        expect(test_subject.private_storage_service_name).to eq(:my_hidden_asset_store)
      end
    end

    context "when private_storage_service_name is a Integer instance" do
      it "raises an error" do
        test_subject.private_storage_service_name = 33

        expect { test_subject.private_storage_service_name }.to raise_error(RuntimeError)
      end
    end

    context "when private_storage_service_name is set to nil" do
      it "returns the private_storage_service_name as nil value" do
        test_subject.private_storage_service_name = nil

        expect(test_subject.private_storage_service_name).to be_nil
      end
    end
  end

  describe ".public_storage_service_name" do
    after { test_subject.public_storage_service_name = nil }

    context "when public_storage_service_name is a Symbol instance" do
      it "returns the public_storage_service_name as a symbol" do
        test_subject.public_storage_service_name = :my_pub_asset_store

        expect(test_subject.public_storage_service_name).to eq(:my_pub_asset_store)
      end
    end

    context "when public_storage_service_name is a String instance" do
      it "returns the public_storage_service_name as a symbol" do
        test_subject.public_storage_service_name = "my_public_asset_store"

        expect(test_subject.public_storage_service_name).to eq(:my_public_asset_store)
      end
    end

    context "when public_storage_service_name is a Integer instance" do
      it "raises an error" do
        test_subject.public_storage_service_name = 33

        expect { test_subject.public_storage_service_name }.to raise_error(RuntimeError)
      end
    end

    context "when public_storage_service_name is set to nil" do
      it "returns the public_storage_service_name as nil value" do
        test_subject.public_storage_service_name = nil

        expect(test_subject.public_storage_service_name).to be_nil
      end
    end
  end

  describe "#cdn_host" do
    after { test_subject.cdn_host = nil }

    it "defaults to true / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.cdn_host).to be_nil
    end

    it "defaults to true / accessible through Aypex::Config" do
      expect(Aypex::Config.cdn_host).to be_nil
    end

    it "is settable directly" do
      test_subject.cdn_host = "https://alpha.com"
      expect(test_subject.cdn_host).to eq "https://alpha.com"
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.cdn_host = "https://foam.com"
      end
      expect(test_subject.cdn_host).to eq "https://foam.com"
    end
  end

  describe "#restock_inventory" do
    after { test_subject.restock_inventory = true }

    it "defaults to true / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.restock_inventory).to be true
    end

    it "defaults to true / accessible through Aypex::Config" do
      expect(Aypex::Config.restock_inventory).to be true
    end

    it "is settable directly" do
      test_subject.restock_inventory = false
      expect(test_subject.restock_inventory).to be false
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.restock_inventory = false
      end
      expect(test_subject.restock_inventory).to be false
    end

    it "returns error if not a Boolean" do
      test_subject.restock_inventory = "string"
      expect { raise "Aypex::Config.restock_inventory MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#track_inventory_levels" do
    after { test_subject.track_inventory_levels = true }

    it "defaults to true / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.track_inventory_levels).to be true
    end

    it "defaults to true / accessible through Aypex::Config" do
      expect(Aypex::Config.track_inventory_levels).to be true
    end

    it "is settable directly" do
      test_subject.track_inventory_levels = false
      expect(test_subject.track_inventory_levels).to be false
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.track_inventory_levels = false
      end
      expect(test_subject.track_inventory_levels).to be false
    end

    it "returns error if not a Boolean" do
      test_subject.track_inventory_levels = "string"
      expect { raise "Aypex::Config.track_inventory_levels MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#disable_store_presence_validation" do
    after { test_subject.disable_store_presence_validation = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.disable_store_presence_validation).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.disable_store_presence_validation).to be false
    end

    it "is settable directly" do
      test_subject.disable_store_presence_validation = true
      expect(test_subject.disable_store_presence_validation).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.disable_store_presence_validation = true
      end
      expect(test_subject.disable_store_presence_validation).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.disable_store_presence_validation = "string"
      expect { raise "Aypex::Config.disable_store_presence_validation MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#address_requires_phone" do
    after { test_subject.address_requires_phone = true }

    it "defaults to true / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.address_requires_phone).to be true
    end

    it "defaults to true / accessible through Aypex::Config" do
      expect(Aypex::Config.address_requires_phone).to be true
    end

    it "is settable directly" do
      test_subject.address_requires_phone = false
      expect(test_subject.address_requires_phone).to be false
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.address_requires_phone = false
      end
      expect(test_subject.address_requires_phone).to be false
    end

    it "returns error if not a Boolean" do
      test_subject.address_requires_phone = "string"
      expect { raise "Aypex::Config.address_requires_phone MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#allow_checkout_on_gateway_error" do
    after { test_subject.allow_checkout_on_gateway_error = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.allow_checkout_on_gateway_error).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.allow_checkout_on_gateway_error).to be false
    end

    it "is settable directly" do
      test_subject.allow_checkout_on_gateway_error = true
      expect(test_subject.allow_checkout_on_gateway_error).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.allow_checkout_on_gateway_error = true
      end
      expect(test_subject.allow_checkout_on_gateway_error).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.allow_checkout_on_gateway_error = "string"

      expect { raise "Aypex::Config.allow_checkout_on_gateway_error MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#auto_capture" do
    after { test_subject.auto_capture = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.auto_capture).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.auto_capture).to be false
    end

    it "is settable directly" do
      test_subject.auto_capture = true
      expect(test_subject.auto_capture).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.auto_capture = true
      end
      expect(test_subject.auto_capture).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.auto_capture = "string"

      expect { raise "Aypex::Config.auto_capture MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#auto_capture_on_dispatch" do
    after { test_subject.auto_capture_on_dispatch = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.auto_capture_on_dispatch).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.auto_capture_on_dispatch).to be false
    end

    it "is settable directly" do
      test_subject.auto_capture_on_dispatch = true
      expect(test_subject.auto_capture_on_dispatch).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.auto_capture_on_dispatch = true
      end
      expect(test_subject.auto_capture_on_dispatch).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.auto_capture_on_dispatch = "string"

      expect { raise "Aypex::Config.auto_capture_on_dispatch MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#expedited_exchanges" do
    after { test_subject.expedited_exchanges = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.expedited_exchanges).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.expedited_exchanges).to be false
    end

    it "is settable directly" do
      test_subject.expedited_exchanges = true
      expect(test_subject.expedited_exchanges).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.expedited_exchanges = true
      end
      expect(test_subject.expedited_exchanges).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.expedited_exchanges = "string"
      expect { raise "Aypex::Config.expedited_exchanges MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#binary_inventory_cache" do
    after { test_subject.binary_inventory_cache = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.binary_inventory_cache).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.binary_inventory_cache).to be false
    end

    it "is settable directly" do
      test_subject.binary_inventory_cache = true
      expect(test_subject.binary_inventory_cache).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.binary_inventory_cache = true
      end
      expect(test_subject.binary_inventory_cache).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.binary_inventory_cache = "string"
      expect { raise "Aypex::Config.binary_inventory_cache MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#credit_to_new_allocation" do
    after { test_subject.credit_to_new_allocation = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.credit_to_new_allocation).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.credit_to_new_allocation).to be false
    end

    it "is settable directly" do
      test_subject.credit_to_new_allocation = true
      expect(test_subject.credit_to_new_allocation).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.credit_to_new_allocation = true
      end
      expect(test_subject.credit_to_new_allocation).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.credit_to_new_allocation = "string"
      expect { raise "Aypex::Config.credit_to_new_allocation MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#disable_sku_validation" do
    after { test_subject.disable_sku_validation = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.disable_sku_validation).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.disable_sku_validation).to be false
    end

    it "is settable directly" do
      test_subject.disable_sku_validation = true
      expect(test_subject.disable_sku_validation).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.disable_sku_validation = true
      end
      expect(test_subject.disable_sku_validation).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.disable_sku_validation = "string"
      expect { raise "Aypex::Config.disable_sku_validation MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#expedited_exchanges_days_window" do
    after { test_subject.expedited_exchanges_days_window = 14 }

    it "defaults to 14 / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.expedited_exchanges_days_window).to eq 14
    end

    it "defaults to 14 / accessible through Aypex::Config" do
      expect(Aypex::Config.expedited_exchanges_days_window).to eq 14
    end

    it "is settable directly" do
      test_subject.expedited_exchanges_days_window = 44
      expect(test_subject.expedited_exchanges_days_window).to eq 44
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.expedited_exchanges_days_window = 66
      end
      expect(test_subject.expedited_exchanges_days_window).to eq 66
    end

    it "returns error if not an Integer" do
      test_subject.expedited_exchanges_days_window = true
      expect { raise "Aypex::Config.expedited_exchanges_days_window MUST be an Integer" }.to raise_error(RuntimeError)
    end
  end

  describe "#non_expiring_credit_types" do
    after { test_subject.non_expiring_credit_types = [] }

    it "defaults to [] / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.non_expiring_credit_types).to eq []
    end

    it "defaults to [] / accessible through Aypex::Config" do
      expect(Aypex::Config.non_expiring_credit_types).to eq []
    end

    it "is settable directly" do
      test_subject.non_expiring_credit_types = ["refunded", "canceled"]
      expect(test_subject.non_expiring_credit_types).to eq ["refunded", "canceled"]
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.non_expiring_credit_types = ["some", "type"]
      end
      expect(test_subject.non_expiring_credit_types).to eq ["some", "type"]
    end

    it "returns error if not an Array" do
      test_subject.non_expiring_credit_types = true
      expect { raise "Aypex::Config.non_expiring_credit_types MUST be an Array" }.to raise_error(RuntimeError)
    end
  end

  describe "#products_per_page" do
    after { test_subject.products_per_page = 12 }

    it "defaults to 12 / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.products_per_page).to eq 12
    end

    it "defaults to 12 / accessible through Aypex::Config" do
      expect(Aypex::Config.products_per_page).to eq 12
    end

    it "is settable directly" do
      test_subject.products_per_page = 55
      expect(test_subject.products_per_page).to eq 55
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.products_per_page = 78
      end
      expect(test_subject.products_per_page).to eq 78
    end

    it "returns error if not an Integer" do
      test_subject.products_per_page = true
      expect { raise "Aypex::Config.products_per_page MUST be an Integer" }.to raise_error(RuntimeError)
    end
  end

  describe "#require_master_price" do
    after { test_subject.require_master_price = true }

    it "defaults to true / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.require_master_price).to be true
    end

    it "defaults to true / accessible through Aypex::Config" do
      expect(Aypex::Config.require_master_price).to be true
    end

    it "is settable directly" do
      test_subject.require_master_price = false
      expect(test_subject.require_master_price).to be false
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.require_master_price = false
      end
      expect(test_subject.require_master_price).to be false
    end

    it "returns error if not a Boolean" do
      test_subject.require_master_price = "string"
      expect { raise "Aypex::Config.require_master_price MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#send_core_emails" do
    after { test_subject.send_core_emails = true }

    it "defaults to true / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.send_core_emails).to be true
    end

    it "defaults to true / accessible through Aypex::Config" do
      expect(Aypex::Config.send_core_emails).to be true
    end

    it "is settable directly" do
      test_subject.send_core_emails = false
      expect(test_subject.send_core_emails).to be false
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.send_core_emails = false
      end
      expect(test_subject.send_core_emails).to be false
    end

    it "returns error if not a Boolean" do
      test_subject.send_core_emails = "string"
      expect { raise "Aypex::Config.send_core_emails MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#show_products_without_price" do
    after { test_subject.show_products_without_price = false }

    it "defaults to false / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.show_products_without_price).to be false
    end

    it "defaults to false / accessible through Aypex::Config" do
      expect(Aypex::Config.show_products_without_price).to be false
    end

    it "is settable directly" do
      test_subject.show_products_without_price = true
      expect(test_subject.show_products_without_price).to be true
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.show_products_without_price = true
      end
      expect(test_subject.show_products_without_price).to be true
    end

    it "returns error if not a Boolean" do
      test_subject.show_products_without_price = "string"
      expect { raise "Aypex::Config.show_products_without_price MUST be a Boolean (true / false)" }.to raise_error(RuntimeError)
    end
  end

  describe "#storefront_products_path" do
    after { test_subject.storefront_products_path = "products" }

    it "defaults to 'products' / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.storefront_products_path).to eq "products"
    end

    it "defaults to 'products' / accessible through Aypex::Config" do
      expect(Aypex::Config.storefront_products_path).to eq "products"
    end

    it "is settable directly" do
      test_subject.storefront_products_path = "items"
      expect(test_subject.storefront_products_path).to eq "items"
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.storefront_products_path = "prods"
      end
      expect(test_subject.storefront_products_path).to eq "prods"
    end

    it "returns error if not an String" do
      test_subject.storefront_products_path = true
      expect { raise "Aypex::Config.storefront_products_path MUST be an String" }.to raise_error(RuntimeError)
    end
  end

  describe "#storefront_categories_path" do
    after { test_subject.storefront_categories_path = "t" }

    it "defaults to 't' / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.storefront_categories_path).to eq "t"
    end

    it "defaults to 't' / accessible through Aypex::Config" do
      expect(Aypex::Config.storefront_categories_path).to eq "t"
    end

    it "is settable directly" do
      test_subject.storefront_categories_path = "cats"
      expect(test_subject.storefront_categories_path).to eq "cats"
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.storefront_categories_path = "categories"
      end
      expect(test_subject.storefront_categories_path).to eq "categories"
    end

    it "returns error if not an String" do
      test_subject.storefront_categories_path = true
      expect { raise "Aypex::Config.storefront_categories_path MUST be an String" }.to raise_error(RuntimeError)
    end
  end

  describe "#storefront_pages_path" do
    after { test_subject.storefront_pages_path = "pages" }

    it "defaults to 'pages' / accessible through Rails.application.config.aypex.preferences" do
      expect(Rails.application.config.aypex.preferences.storefront_pages_path).to eq "pages"
    end

    it "defaults to 'pages' / accessible through Aypex::Config" do
      expect(Aypex::Config.storefront_pages_path).to eq "pages"
    end

    it "is settable directly" do
      test_subject.storefront_pages_path = "pee"
      expect(test_subject.storefront_pages_path).to eq "pee"
    end

    it "is settable via block" do
      Aypex.configure do |config|
        config.storefront_pages_path = "page"
      end
      expect(test_subject.storefront_pages_path).to eq "page"
    end

    it "returns error if not an String" do
      test_subject.storefront_pages_path = true
      expect { raise "Aypex::Config.storefront_pages_path MUST be an String" }.to raise_error(RuntimeError)
    end
  end
end
