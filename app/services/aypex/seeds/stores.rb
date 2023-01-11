module Aypex
  module Seeds
    class Stores
      prepend Aypex::ServiceModule::Base

      def call
        Aypex::Store.new do |s|
          s.name = "Aypex Demo Site"
          s.code = "aypex"
          s.url = Rails.application.routes.default_url_options[:host] || "demo.aypex.io"
          s.mail_from_address = "no-reply@example.com"
          s.customer_support_email = "support@example.com"
          s.default_currency = "USD"
          s.default_locale = I18n.locale
          s.seo_title = "Aypex Commerce Demo Shop"
          s.meta_description = "This is the new Aypex UX DEMO | OVERVIEW: http://bit.ly/new-aypex-ux | DOCS: http://bit.ly/aypex-ux-customization-docs | CONTACT: https://aypex.io/contact/"
          s.facebook = "aypexcommerce"
          s.twitter = "aypexcommerce"
          s.instagram = "aypexcommerce"
        end.save!
      end
    end
  end
end
