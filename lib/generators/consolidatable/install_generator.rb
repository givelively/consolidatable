# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Consolidatable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('./templates', __dir__)
      desc 'Install Consolidatable'

      def self.next_migration_number(path)
        ActiveRecord::Generators::Base.next_migration_number(path)
      end

      def copy_migrations
        migration_template(
          'migration.rb.erb',
          'db/migrate/create_consolidatable_table.rb',
          migration_version: migration_version
        )
      end

      def create_initializer
        template 'initializer.rb.erb', 'config/initializers/consolidatable.rb'
      end

      def migration_version
        return unless ActiveRecord.version.version > '5'

        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
