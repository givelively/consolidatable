# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Consolidatable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      class_option :json_metadata, type: :boolean, default: true

      source_root File.expand_path('../templates', __dir__)

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

      def migration_version
        return unless ActiveRecord.version.version > '5'

        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
