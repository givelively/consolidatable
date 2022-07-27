# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcherJob < ::ActiveJob::Base
    def perform(owner_class:, owner_id:, variable_hash:, computer:, not_older_than:)
      owner = owner_class.constantize.find(owner_id)
      variable = Variable.factory(variable_hash)

      Consolidatable::InlineConsolidationFetcher.new(
        owner: owner,
        variable: variable,
        computer: computer,
        not_older_than: not_older_than
      ).call
    end
  end
end
