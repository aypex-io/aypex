unless defined?(Aypex::InstallGenerator)
  require "generators/aypex/install/install_generator"
end

require "generators/aypex/dummy/dummy_generator"
require "generators/aypex/dummy_model/dummy_model_generator"

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app, :user_class do |_t, args|
    args.with_defaults(user_class: "Aypex::LegacyUser", install_api: false, install_admin: false, install_checkout: false, install_emails: false, install_storefront: false)
    require ENV["LIB_NAME"].to_s

    ENV["RAILS_ENV"] = "test"
    Rails.env = "test"

    $stdout.puts "(1 of 4) Building dummy app for testing #{ENV.fetch("LIB_NAME", nil)}"
    Aypex::DummyGenerator.start ["--lib_name=#{ENV.fetch("LIB_NAME", nil)}", "--quiet"]
    Aypex::InstallGenerator.start [
      "--lib_name=#{ENV.fetch("LIB_NAME", nil)}",
      "--auto-accept",
      "--migrate=false",
      "--seed=false",
      "--sample=false",
      "--quiet",
      "--copy_storefront=false",
      "--install_api=#{args[:install_admin]}",
      "--install_admin=#{args[:install_admin]}",
      "--install_checkout=#{args[:install_checkout]}",
      "--install_emails=#{args[:install_emails]}",
      "--install_storefront=#{args[:install_storefront]}",
      "--user_class=#{args[:user_class]}"
    ]

    $stdout.puts "(2 of 4) Setting up dummy database..."
    system("bin/rails db:environment:set RAILS_ENV=test")
    system("bundle exec rake db:drop db:create")
    Aypex::DummyModelGenerator.start
    system("bundle exec rake db:migrate")

    $stdout.puts "(3 of 4) Running installation generator for #{ENV["LIB_NAME"]}..."
    begin
      require "generators/#{ENV["LIB_NAME"]}/install/install_generator"
      $stdout.puts "Running extension installation generator..."
      "#{ENV["LIB_NAME"].camelize}::InstallGenerator".constantize.start(["--auto-run-migrations"])
    rescue LoadError
      $stdout.puts "Skipping installation no generator to run..."
    end

    $stdout.puts "(4 of 4) Precompiling assets..."
    system("bundle exec rake assets:precompile")

    $stdout.puts "Fin!"
  end

  task :seed do |_t|
    $stdout.puts "Seeding ..."
    system("bundle exec rake db:seed RAILS_ENV=test")
  end
end
