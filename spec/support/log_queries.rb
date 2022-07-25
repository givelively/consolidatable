# frozen_string_literal: true

def log_queries(&block)
  queries = []
  counter_f =
    lambda do |_name, _started, _finished, _unique_id, payload|
      queries << payload[:name] unless %w[CACHE SCHEMA].include?(payload[:name])
    end
  ActiveSupport::Notifications.subscribed(
    counter_f,
    'sql.active_record',
    &block
  )
  queries
end
