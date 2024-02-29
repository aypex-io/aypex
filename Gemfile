source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw]

%w[
  actionmailer actionpack actionview activejob activemodel activerecord
  activestorage activesupport railties actiontext
].each do |rails_gem|
  gem rails_gem, ENV.fetch("RAILS_VERSION", "~> 7.0.0"), require: false
end

platforms :jruby do
  gem "jruby-openssl"
end

platforms :ruby do
  if ENV["DB"] == "mysql"
    gem "mysql2"
  else
    gem "pg"
  end
end

group :test do
  gem "capybara"
  gem "capybara-screenshot"
  gem "database_cleaner-active_record"
  gem "factory_bot_rails"
  gem "ffaker"
  gem "propshaft"
  gem "puma"
  gem "redis"
  gem "rails-controller-testing"
  gem "rspec-activemodel-mocks"
  gem "rspec_junit_formatter"
  gem "rspec-rails"
  gem "rspec-retry"
  gem "rswag-specs"
  gem "simplecov"
  gem "timecop"
  gem "webdrivers"
  gem "webmock"
end

group :test, :development do
  gem "awesome_print"
  gem "debug"
  gem "gem-release"
  gem "i18n-tasks"
  gem "rubocop"
  gem "rubocop-rspec"
  gem "standard", "~> 1.0"
end

group :development do
  gem "erb_lint"
end

gemspec
