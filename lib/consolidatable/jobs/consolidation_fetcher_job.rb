# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcherJob < ::ActiveJob::Base
    def perform(owner_class, owner_id, variable, computer)
      owner = owner_class.constantize.find(owner_id)
      return if owner.blank?

      owner.consolidations.create(
        var_name: variable.name,
        var_type: variable.type,
        "#{variable.type}_value": owner.send(computer)
      )
    end
  end
end
