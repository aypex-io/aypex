module Aypex
  class Engine < ::Rails::Engine
    def self.admin_available?
      @admin_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Aypex::Admin::Engine")
    end

    def self.api_available?
      @api_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Aypex::Api::Engine")
    end

    def self.checkout_available?
      @checkout_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Aypex::Checkout::Engine")
    end

    def self.cli_available?
      @cli_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Aypex::Cli::Engine")
    end

    def self.emails_available?
      @emails_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Aypex::Emails::Engine")
    end

    def self.sample_available?
      @sample_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("AypexSample::Engine")
    end

    def self.storefront_available?
      @storefront_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Aypex::Storefront::Engine")
    end
  end
end
