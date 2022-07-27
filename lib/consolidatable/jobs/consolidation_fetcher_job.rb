# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcherJob < ::ActiveJob::Base
    def perform(owner_class, owner_id, var_name, var_type, computer)
      owner = owner_class.constantize.find(owner_id)
      return if owner.blank?

      owner.consolidations.create(
        var_name: var_name,
        var_type: var_type,
        "#{var_type}_value": owner.send(computer)
      )
    end
  end
end
