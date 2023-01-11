require "rails/generators"
require "highline/import"
require "bundler"
require "bundler/cli"
require "active_support/core_ext/string/indent"
require "aypex"

module Aypex
  class InstallGenerator < Rails::Generators::Base
    class_option :migrate, type: :boolean, default: true, banner: "Run Aypex migrations"
    class_option :seed, type: :boolean, default: true, banner: "load seed data (migrations must be run)"
    class_option :sample, type: :boolean, default: false, banner: "load sample data (migrations must be run)"
    class_option :install_storefront, type: :boolean, default: false, banner: "installs default rails storefront"
    class_option :install_checkout, type: :boolean, default: false, banner: "installs default rails checkout"
    class_option :install_emails, type: :boolean, default: false, banner: "installs default rails emails"
    class_option :install_admin, type: :boolean, default: false, banner: "installs default rails admin"
    class_option :copy_storefront, type: :boolean, default: false, banner: "copy all storefront views and stylesheets"
    class_option :auto_accept, type: :boolean
    class_option :user_class, type: :string
    class_option :admin_email, type: :string
    class_option :admin_password, type: :string
    class_option :lib_name, type: :string, default: "aypex"
    class_option :enforce_available_locales, type: :boolean, default: nil

    def self.source_paths
      paths = superclass.source_paths
      paths << File.expand_path("../templates", "../../#{__FILE__}")
      paths << File.expand_path("../templates", "../#{__FILE__}")
      paths << File.expand_path("templates", __dir__)
      paths.flatten
    end

    def prepare_options
      @run_migrations = options[:migrate]
      @load_seed_data = options[:seed]
      @load_sample_data = options[:sample]
      @install_admin = options[:install_admin]
      @install_checkout = options[:install_checkout]
      @install_emails = options[:install_emails]
      @install_storefront = options[:install_storefront]
      @copy_storefront = options[:copy_storefront]

      unless @run_migrations
        @load_seed_data = false
        @load_sample_data = false
      end
    end

    def add_files
      template "config/initializers/aypex.rb", "config/initializers/aypex.rb"
    end

    def additional_tweaks
      return unless File.exist? "public/robots.txt"

      append_file "public/robots.txt", <<-ROBOTS.strip_heredoc
        User-agent: *
        Disallow: /checkout
        Disallow: /cart
        Disallow: /orders
        Disallow: /user
        Disallow: /account
        Disallow: /api
        Disallow: /password
        Disallow: /api_tokens
        Disallow: /cart_link
        Disallow: /account_link
      ROBOTS
    end

    def create_overrides_directory
      empty_directory "app/overrides"
    end

    def install_admin
      if @install_admin && Aypex::Engine.admin_available?
        puts "Installing Aypex Admin"
        generate "aypex:admin:install --migrate=false --add_migrations=false"
      end
    end

    def install_checkout
      if @install_checkout && Aypex::Engine.checkout_available?
        puts "Installing Aypex Checkout"
        generate "aypex:checkout:install"
      end
    end

    def install_emails
      if @install_emails && Aypex::Engine.emails_available?
        puts "Installing Aypex Emails"
        generate "aypex:emails:install"
      end
    end

    def install_storefront
      if @install_storefront && Aypex::Engine.storefront_available?
        puts "Installing Aypex Storefront"
        generate "aypex:storefront:install"
      end
    end

    def copy_storefront
      if @copy_storefront && Aypex::Engine.storefront_available?
        puts "Copying Aypex Storefront view files"
        generate "aypex:storefront:copy_storefront"
      end
    end

    def configure_application
      application <<-APP.strip_heredoc.indent!(4)

        config.to_prepare do
          # Load application's model / class decorators
          Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
            Rails.configuration.cache_classes ? require(c) : load(c)
          end

          # Load application's view overrides
          Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
            Rails.configuration.cache_classes ? require(c) : load(c)
          end
        end
      APP

      unless options[:enforce_available_locales].nil?
        application <<-APP.strip_heredoc.indent!(4)
          # Prevent this deprecation message: https://github.com/svenfuchs/i18n/commit/3b6e56e
          I18n.enforce_available_locales = #{options[:enforce_available_locales]}
        APP
      end
    end

    def include_seed_data
      append_file "db/seeds.rb", <<-SEEDS.strip_heredoc

        Aypex::Engine.load_seed if defined?(Aypex)
        Aypex::Auth::Engine.load_seed if defined?(Aypex::Auth)
      SEEDS
    end

    def install_migrations
      say_status :copying, "migrations"
      silence_stream($stdout) do
        silence_warnings { rake "railties:install:migrations" }
      end
    end

    def create_database
      say_status :creating, "database"
      silence_stream($stdout) do
        silence_stream($stdout) do
          silence_warnings { rake "db:create" }
        end
      end
    end

    def run_migrations
      if @run_migrations
        say_status :running, "migrations"
        silence_stream($stdout) do
          silence_stream($stdout) do
            silence_warnings { rake "db:migrate" }
          end
        end
      else
        say_status :skipping, "migrations (don't forget to run rake db:migrate)"
      end
    end

    def populate_seed_data
      if @load_seed_data
        say_status :loading, "seed data"
        rake_options = []
        rake_options << "AUTO_ACCEPT=1" if options[:auto_accept]
        rake_options << "ADMIN_EMAIL=#{options[:admin_email]}" if options[:admin_email]
        rake_options << "ADMIN_PASSWORD=#{options[:admin_password]}" if options[:admin_password]

        cmd = -> { rake("db:seed #{rake_options.join(" ")}") }
        if options[:auto_accept] || (options[:admin_email] && options[:admin_password])
          silence_stream($stdout) do
            silence_stream($stdout) do
              silence_warnings(&cmd)
            end
          end
        else
          cmd.call
        end
      else
        say_status :skipping, "seed data (you can always run rake db:seed)"
      end
    end

    def load_sample_data
      return unless Aypex::Engine.sample_available?

      if @load_sample_data
        say_status :loading, "sample data"
        silence_stream($stdout) do
          silence_stream($stdout) do
            silence_warnings { rake "aypex_sample:load" }
          end
        end
      else
        say_status :skipping, "sample data (you can always run rake aypex_sample:load)"
      end
    end

    def notify_about_routes
      insert_into_file(File.join("config", "routes.rb"),
        after: "Rails.application.routes.draw do\n") do
        <<-ROUTES.strip_heredoc.indent!(2)
          # This line mounts Aypex's routes at the root of your application.
          # This means, any requests to URLs such as /products, will go to
          # Aypex::ProductsController.
          # If you would like to change where this engine is mounted, simply change the
          # :at option to something different.
          #
          # We ask that you don't use the :as option here, as Aypex relies on it being
          # the default of "aypex".
          mount Aypex::Engine, at: '/'
        ROUTES
      end

      unless options[:quiet]
        puts "*" * 50
        puts "We added the following line to your application's config/routes.rb file:"
        puts " "
        puts "    mount Aypex::Engine, at: '/'"
      end
    end

    def complete
      unless options[:quiet]
        puts "*" * 50
        puts "Aypex has been installed successfully. You're all ready to go!"
        puts " "
        puts "Enjoy!"
      end
    end

    protected

    def javascript_exists?(script)
      extensions = %w[.js.coffee .js.erb .js.coffee.erb .js]
      file_exists?(extensions, script)
    end

    def stylesheet_exists?(stylesheet)
      extensions = %w[.css.scss .css.erb .css.scss.erb .css]
      file_exists?(extensions, stylesheet)
    end

    def file_exists?(extensions, filename)
      extensions.detect do |extension|
        File.exist?("#{filename}#{extension}")
      end
    end

    private

    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen((RbConfig::CONFIG["host_os"] =~ /mswin|mingw/) ? "NUL:" : "/dev/null")
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
      old_stream.close
    end
  end
end
