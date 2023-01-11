ENV["RAILS_ENV"] ||= "test"

begin
  require File.expand_path("../../tmp/dummy/config/environment", __FILE__)
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake test_app`"
end

require "rspec/rails"
require "database_cleaner/active_record"
require "ffaker"

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

require "testing_support/i18n" if ENV["CHECK_TRANSLATIONS"]

require "testing_support/factories"
require "testing_support/jobs"
require "testing_support/metadata"
require "testing_support/url_helpers"
require "testing_support/kernel"
require "testing_support/rspec_retry_config"

RSpec.configure do |config|
  config.color = true
  config.default_formatter = "doc"
  config.fail_fast = ENV["FAIL_FAST"] || false
  config.fixture_path = File.join(__dir__, "fixtures")
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.raise_errors_for_deprecations!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Clean out the database state before the tests run
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    # Force jobs to be executed in a synchronous way
    ActiveJob::Base.queue_adapter = :inline
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before do
    Rails.cache.clear

    country = create(:country, name: "United States of America", iso_name: "UNITED STATES", iso: "US", iso3: "USA", states_required: true)
    create(:store, default: true, default_country: country, default_currency: "USD")
  rescue Errno::ENOTEMPTY
  end

  config.include FactoryBot::Syntax::Methods
  config.include Aypex::TestingSupport::Kernel

  config.before(:suite) do
    # Clean out the database state before the tests run
    DatabaseCleaner.clean_with(:truncation)
  end

  config.order = :random
  Kernel.srand config.seed
end
