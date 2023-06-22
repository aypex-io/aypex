module Aypex
  module ControllerHelpers
    module Auth
      extend ActiveSupport::Concern
      include Aypex::TokenGenerator

      included do
        before_action :set_token

        if defined?(helper_method)
          helper_method :try_aypex_current_user
        end

        rescue_from CanCan::AccessDenied do |_exception|
          redirect_unauthorized_access
        end
      end

      # Needs to be overridden so that we use Aypex's Ability rather than anyone else's.
      def current_ability
        @current_ability ||= Aypex::Dependency.ability_class.constantize.new(try_aypex_current_user)
      end

      def redirect_back_or_default(default)
        redirect_to(session["aypex_user_return_to"] || request.env["HTTP_REFERER"] || default)
        session["aypex_user_return_to"] = nil
      end

      def set_token
        cookies.permanent.signed[:token] ||= cookies.signed[:guest_token]
        cookies.permanent.signed[:token] ||= {
          value: generate_token,
          httponly: true
        }
        cookies.permanent.signed[:guest_token] ||= cookies.permanent.signed[:token]
      end

      def current_oauth_token
        get_last_access_token = ->(user) { Aypex::OauthAccessToken.active_for(user).where(expires_in: nil).last }
        create_access_token = ->(user) { Aypex::OauthAccessToken.create!(resource_owner: user) }
        user = try_aypex_current_user
        return unless user

        @current_oauth_token ||= get_last_access_token.call(user) || create_access_token.call(user)
      end

      def store_location
        # disallow return to login, logout, signup pages
        authentication_routes = [:aypex_signup_path, :aypex_login_path, :aypex_logout_path]
        disallowed_urls = []
        authentication_routes.each do |route|
          disallowed_urls << send(route) if respond_to?(route)
        end

        disallowed_urls.map! { |url| url[/\/\w+$/] }
        unless disallowed_urls.include?(request.fullpath)
          session["aypex_user_return_to"] = request.fullpath.gsub("//", "/")
        end
      end

      # proxy method to *possible* aypex_current_user method
      # Authentication extensions (such as aypex_auth_devise) are meant to provide aypex_current_user
      def try_aypex_current_user
        # This one will be defined by apps looking to hook into Aypex
        # As per authentication_helpers.rb
        if respond_to?(:aypex_current_user)
          aypex_current_user
        # This one will be defined by Devise
        elsif respond_to?(:current_aypex_user)
          current_aypex_user
        end
      end
    end
  end
end
