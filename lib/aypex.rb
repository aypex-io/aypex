require "action_controller/railtie"
require "action_view/railtie"
require "active_job/railtie"
require "active_model/railtie"
require "active_record/railtie"
require "active_storage/engine"

require "active_merchant"
require "active_storage_validations"
require "activerecord-typedstore"
require "acts_as_list"
require "auto_strip_attributes"
require "awesome_nested_set"
require "cancan"
require "friendly_id"
require "friendly_id/paranoia"
require "image_processing/mini_magick"
require "kaminari"
require "monetize"
require "paranoia"
require "ransack"
require "state_machines-activerecord"

# This is required because ActiveModel::Validations#invalid? conflicts with the
# invalid state of a Payment. In the future this should be removed.
StateMachines::Machine.ignore_method_conflicts = true

module Aypex
  autoload :ProductFilters, "aypex/product_filters"
  autoload :TokenGenerator, "aypex/token_generator"

  class GatewayError < RuntimeError; end

  class DestroyWithOrdersError < StandardError; end

  # Used to configure Aypex.
  #
  # Example:
  #
  #   Aypex.configure do |config|
  #     config.track_inventory_levels = false
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Aypex.
  def self.configure
    yield(Aypex::Config)
  end

  # Used to set a new dependency for Aypex.
  #
  # Example:
  #
  #   Aypex.set_dependency do |dependency|
  #     dependency.cart_add_item_service = MyCustomAddToCart
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Aypex.
  def self.set_dependency
    yield(Aypex::Dependency)
  end
end

require "aypex/version"
require "aypex/number_generator"
require "aypex/migrations"
require "aypex/engine"

require "aypex/i18n"
require "aypex/localized_number"
require "aypex/money"
require "aypex/permitted_attributes"
require "aypex/service_module"
require "aypex/database_type_utilities"

require "aypex/importer"
require "aypex/query_filters"
require "aypex/product_duplicator"
require "aypex/controller_helpers/auth"
require "aypex/controller_helpers/order"
require "aypex/controller_helpers/search"
require "aypex/controller_helpers/store"
require "aypex/controller_helpers/strong_parameters"
require "aypex/controller_helpers/locale"
require "aypex/controller_helpers/currency"
