# Aypex Configurations
# Note: Setting a config here will NOT be stored in the database.
#       removing a config entry from this initializer will make the setting
#       revert back it's default value.
#
Aypex.config do |config|
  config.user_class = <%= (options[:user_class].blank? ? "Aypex::LegacyUser" : options[:user_class]).inspect %>
end


# Aypex Dependencies
# Note: If a dependency is set here it will NOT be stored within the cache & database upon initialization.
#       removing an entry from this initializer will make the dependency value go away.
#
Aypex.dependency do |dependent|
  # Examples:
  # Un-comment to change the default Service handling adding Items to Cart
  # dependent.cart_add_item_service = "MyNewAwesomeService"

  # Un-comment to set the default storefront cart serializer
  # dependent.storefront_cart_serializer = "MyRailsApp::CartSerializer"
end

