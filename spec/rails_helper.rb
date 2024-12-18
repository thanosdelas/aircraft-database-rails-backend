# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

AIRCRAFT_TYPES = [
  'Airliner',
  'Business Jet',
  'Utility Helicopter',
  'Multirole Combat Aircraft',
  'Fighter Aircraft',
  'Transport',
  'Trainer',
  'Unmanned Combat Aerial Vehicle'

].freeze

MANUFACTURER_GROUPS = [
  'Airbus',
  'Boeing',
  'Bell'
].freeze

MANUFACTURERS = [
  'Airbus',
  'Airbus Helicopters',
  'Airbus Defence And Space',
  'Bell Aircraft',
  'Bell Helicopter',
  'Boeing',
  'Boeing Helicopters',
  'Boeing Commercial Airplanes',
  'Antonov',
  'Beechcraft',
  'Canadair',
  'Lockheed',
  'McDonnell',
  'North American',
  'Northrop',
  'Sukhoi',
  'Tupolev',
  'Beriev',
  'AgustaWestland'
].freeze

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    [
      { id: 100, group: 'admin' },
      { id: 200, group: 'user' },
      { id: 300, group: 'guest' }
    ].each do |group|
      UserGroup.find_or_create_by!(id: group[:id], group: group[:group])
    end

    AIRCRAFT_TYPES.each do |aircraft_type|
      FactoryBot.create(:type, aircraft_type: aircraft_type)
    end

    MANUFACTURER_GROUPS.each do |manufacturer_group|
      FactoryBot.create(:manufacturer_group, manufacturer_group: manufacturer_group)
    end

    MANUFACTURERS.each do |manufacturer|
      manufacturer_group = nil
      manufacturer_group = 'Airbus' if manufacturer.include?('Airbus')
      manufacturer_group = 'Boeing' if manufacturer.include?('Boeing')
      manufacturer_group = 'Bell' if manufacturer.include?('Bell')

      FactoryBot.create(:manufacturer, manufacturer: manufacturer, manufacturer_group_string: manufacturer_group)
    end
  end

  config.after(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
