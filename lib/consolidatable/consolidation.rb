# frozen_string_literal: true

module Consolidatable
  class Consolidation < ActiveRecord::Base
    belongs_to :consolidatable, polymorphic: true, validate: { presence: true }

    def self.fetch(obj, var_name:, var_type:, calculator:, not_older_than:)
      cons = obj.consolidations.detect do |c|
        c.var_name == var_name && c.var_type.to_sym == var_type
      end || obj.consolidations.find_by(var_name: var_name, var_type: var_type)

      return cons.value if !cons.nil? && !cons.stale?(not_older_than)

      result_value = obj.send(calculator)

      if cons.nil?
        cons = obj.consolidations.create(var_name: var_name,
                                         var_type: var_type,
                                         "#{var_type}_value": result_value)
      elsif cons.stale?(not_older_than)
        cons.update("#{var_type}_value": result_value, updated_at: Time.current)
      end

      cons.value
    end

    def self.consolidate_them_all
      ::Consolidation.all.distinct.pluck(:consolidatable_type).each do |klass|
        glass = klass.constantize
        glass.send(:class_variable_get, '@@consolidate_methods').each do |m|
          glass.find_each { |g| g.send(m) }
        end
      end
    end

    def stale?(not_older_than)
      updated_at < not_older_than
    end

    def value
      send("#{var_type}_value")
    end
  end
end
