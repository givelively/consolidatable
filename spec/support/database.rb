# frozen_string_literal: true

FileUtils.mkdir_p 'tmp'

database_config_file = File.join(__dir__, '../database/database.yml')

ActiveRecord::Base.belongs_to_required_by_default = true if ActiveRecord.version.version >= '5'
database_config_raw = File.read(database_config_file)
database_config_yaml = ERB.new(database_config_raw).result
database_config = YAML.safe_load(database_config_yaml)
ActiveRecord::Base.establish_connection(database_config['test'])

RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.strategy = :truncation }

  config.before { DatabaseCleaner.clean }
end
