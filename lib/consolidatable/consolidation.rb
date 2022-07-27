# frozen_string_literal: true

module Consolidatable
  class Consolidation < ::ActiveRecord::Base
    belongs_to :consolidatable, polymorphic: true, validate: { presence: true }

    scope :find_variable,
          lambda { |variable|
            where(var_name: variable.name, var_type: variable.type)
          }

    def self.detect(collection, variable)
      collection.detect do |c|
        c.var_name == variable.name && c.var_type.to_sym == variable.type
      end
    end

    def destale!(new_value)
      self.value = new_value
      self.updated_at = Time.current - rand(5).seconds
      save
    end

    def stale?(not_older_than)
      updated_at < (Time.current - not_older_than)
    end

    def value
      send("#{var_type}_value")
    end

    def value=(value)
      send("#{var_type}_value=", value)
    end
  end
end
