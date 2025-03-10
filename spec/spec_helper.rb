# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'spec/'
  add_filter '.github/'
  add_filter 'lib/generators/templates/'
  add_filter 'lib/consolidatable/version'
  add_filter 'lib/consolidatable/configurable'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'yaml'
require 'erb'
require 'active_record'
require 'database_cleaner'
require 'consolidatable'

# Configure the test database
db_config = YAML.safe_load(
  ERB.new(
    File.read(File.expand_path('database/database.yml', __dir__))
  ).result
)['test']

ActiveRecord::Base.establish_connection(db_config)

# Load schema
load File.expand_path('database/schema.rb', __dir__)

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Clear any class configurations between tests
  config.before do
    if defined?(Child) && Child.respond_to?(:consolidations_config)
      Child.consolidations_config.clear
    end
  end
end
