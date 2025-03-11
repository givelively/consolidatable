# frozen_string_literal: true

require 'active_record'

def db_config
  {
    adapter: 'postgresql',
    host: ENV.fetch('POSTGRES_HOST', 'localhost'),
    database: ENV.fetch('POSTGRES_DB', 'consolidatable_test'),
    username: ENV.fetch('POSTGRES_USER', 'postgres'),
    password: ENV.fetch('POSTGRES_PASSWORD', 'postgres'),
    encoding: 'unicode',
    pool: ENV.fetch('POSTGRES_POOL', 5).to_i,
    min_messages: 'warning'
  }
end

ActiveRecord::Base.establish_connection(db_config)
