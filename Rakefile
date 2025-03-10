# frozen_string_literal: true

require 'rake'

begin
  require 'bundler/setup'
  Bundler::GemHelper.install_tasks
rescue LoadError
  puts 'although not required, bundler is recommened for running the tests'
end

task default: :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-performance'
  task.requires << 'rubocop-rspec'
end

require 'rails'
require 'erb'

task environment: :environment do
  database_config_file = File.join(__dir__, 'spec/database/database.yml')

  database_config_raw = File.read(database_config_file)
  database_config_yaml = ERB.new(database_config_raw).result
  database_config = YAML.safe_load(database_config_yaml)

  ActiveRecord::Tasks::DatabaseTasks.database_configuration = database_config
  ActiveRecord::Tasks::DatabaseTasks.db_dir = 'spec/database'
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = []
  ActiveRecord::Tasks::DatabaseTasks.root = './'
end

load 'active_record/railties/databases.rake'
