# frozen_string_literal: true

require 'active_record'

db_config = {
  'test' => {
    'adapter' => 'postgresql',
    'encoding' => 'unicode',
    'host' => ENV.fetch('POSTGRES_HOST', 'localhost'),
    'database' => ENV.fetch('POSTGRES_DB', 'consolidatable_test'),
    'username' => ENV.fetch('POSTGRES_USER', 'postgres'),
    'password' => ENV.fetch('POSTGRES_PASSWORD', 'postgres'),
    'pool' => ENV.fetch('POSTGRES_POOL', 5).to_i,
    'min_messages' => 'warning'
  }
}

ActiveRecord::Base.belongs_to_required_by_default = true if ActiveRecord.version.version >= '5'
ActiveRecord::Base.establish_connection(db_config['test'])

# Load and apply the schema
load File.expand_path('../database/schema.rb', __dir__)

RSpec.configure do |config|
  config.before(:suite) do 
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before { DatabaseCleaner.clean }
end
