# frozen_string_literal: true

# Aypex Dependencies
# Note: If a dependency is set here it will NOT be stored within the cache & database upon initialization.
#       removing an entry from this initializer will make the dependency value go away.
#
Aypex.set_dependency do |dependency|
  # Examples:
  # Un-comment to change the default Service handling adding Items to Cart
  # dependency.cart_add_item_service = "MyNewAwesomeService"

  # Un-comment to set the default storefront cart serializer
  # dependency.storefront_cart_serializer = "MyRailsApp::CartSerializer"
end

# Aypex Configurations
# Note: Setting a config here will NOT be stored in the database.
#       removing a config entry from this initializer will make the setting
#       revert back it's default value.
#
Aypex.configure do |config|
  config.searcher_class = <%= (options[:user_class].blank? ? "Aypex::LegacyUser" : options[:user_class]).inspect %>
end
