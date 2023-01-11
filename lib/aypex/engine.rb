require_relative "dependencies"
require_relative "configuration"

module Aypex
  class Engine < ::Rails::Engine
    Environment = Struct.new(
      :calculators,
      :preferences,
      :dependencies,
      :payment_methods,
      :adjusters,
      :stock_splitters,
      :promotions,
      :line_item_comparison_hooks
    )

    AypexCalculators = Struct.new(
      :shipping_methods,
      :tax_rates,
      :promotion_actions_create_adjustments,
      :promotion_actions_create_item_adjustments
    )

    PromoEnvironment = Struct.new(
      :rules,
      :actions
    )

    isolate_namespace Aypex
    engine_name "aypex"

    rake_tasks do
      load File.join(root, "lib", "tasks", "exchanges.rake")
    end

    initializer "aypex.environment", before: :load_config_initializers do |app|
      app.config.aypex = Environment.new(AypexCalculators.new, Aypex::Configuration.new, Aypex::Dependencies.new)
      app.config.active_record.yaml_column_permitted_classes = [Symbol, BigDecimal]
      Aypex::Config = app.config.aypex.preferences
      Aypex::Dependency = app.config.aypex.dependencies
    end

    initializer "aypex.register.calculators", before: :after_initialize do |app|
    end

    initializer "aypex.register.stock_splitters", before: :load_config_initializers do |app|
    end

    initializer "aypex.register.line_item_comparison_hooks", before: :load_config_initializers do |app|
      app.config.aypex.line_item_comparison_hooks = Set.new
    end

    initializer "aypex.register.payment_methods", after: "acts_as_list.insert_into_active_record" do |app|
    end

    initializer "aypex.register.adjustable_adjusters" do |app|
    end

    # We need to define promotions rules here so extensions and existing apps
    # can add their custom classes on their initializer files
    initializer "aypex.promo.environment" do |app|
      app.config.aypex.promotions = PromoEnvironment.new
      app.config.aypex.promotions.rules = []
    end

    initializer "aypex.promo.register.promotion.calculators" do |app|
    end

    # Promotion rules need to be evaluated on after initialize otherwise
    # Aypex::Config.user_class would be nil and users might experience errors related
    # to malformed model associations (Aypex::Config.user_class is only defined on
    # the app initializer)
    config.after_initialize do
      Rails.application.config.aypex.calculators.shipping_methods = [
        Aypex::Calculator::Shipping::FlatPercentItemTotal,
        Aypex::Calculator::Shipping::FlatRate,
        Aypex::Calculator::Shipping::FlexiRate,
        Aypex::Calculator::Shipping::PerItem,
        Aypex::Calculator::Shipping::PriceSack,
        Aypex::Calculator::Shipping::DigitalDelivery
      ]

      Rails.application.config.aypex.calculators.tax_rates = [
        Aypex::Calculator::Tax::Default
      ]

      Rails.application.config.aypex.calculators.promotion_actions_create_item_adjustments = [
        Aypex::Calculator::Promotion::PercentOnLineItem,
        Aypex::Calculator::Promotion::FixedAmount,
        Aypex::Calculator::Promotion::FlatRate,
        Aypex::Calculator::Promotion::FlexiRate
      ]

      Rails.application.config.aypex.stock_splitters = [
        Aypex::Stock::Splitter::ShippingCategory,
        Aypex::Stock::Splitter::Backordered,
        Aypex::Stock::Splitter::Digital
      ]

      Rails.application.config.aypex.payment_methods = [
        Aypex::Gateway::Bogus,
        Aypex::Gateway::BogusSimple,
        Aypex::PaymentMethod::Check,
        Aypex::PaymentMethod::StoreCredit
      ]

      Rails.application.config.aypex.adjusters = [
        Aypex::Adjustable::Adjuster::Promotion,
        Aypex::Adjustable::Adjuster::Tax
      ]

      Rails.application.config.aypex.promotions.rules.concat [
        Aypex::Promotion::Rules::ItemTotal,
        Aypex::Promotion::Rules::Product,
        Aypex::Promotion::Rules::User,
        Aypex::Promotion::Rules::FirstOrder,
        Aypex::Promotion::Rules::UserLoggedIn,
        Aypex::Promotion::Rules::OneUsePerUser,
        Aypex::Promotion::Rules::Taxon,
        Aypex::Promotion::Rules::OptionValue,
        Aypex::Promotion::Rules::Country
      ]

      Rails.application.config.aypex.promotions.actions = [
        Promotion::Actions::CreateItemAdjustments,
        Promotion::Actions::CreateLineItems,
        Promotion::Actions::FreeShipping
      ]
    end

    initializer "aypex.promo.register.promotions.actions" do |app|
    end

    # filter sensitive information during logging
    initializer "aypex.params.filter" do |app|
      app.config.filter_parameters += [
        :password,
        :password_confirmation,
        :number,
        :verification_value,
        :client_id,
        :client_secret,
        :refresh_token
      ]
    end

    initializer "aypex.core.checking_migrations" do
      Migrations.new(config, engine_name).check
    end

    config.to_prepare do
      # Ensure aypex locale paths are present before decorators
      I18n.load_path.unshift(*(Dir.glob(
        File.join(
          File.dirname(__FILE__), "../../../config/locales", "*.{rb,yml}"
        )
      ) - I18n.load_path))

      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
  end
end

require "aypex/routes"
require "aypex/components"
