# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcherJob < ::ActiveJob::Base
    def perform(owner_class, owner_id, variable, computer, not_older_than)
      owner = owner_class.constantize.find(owner_id)
      InlineConsolidationFetcher.new(
        owner: owner,
        computer: computer,
        variable: variable,
        not_older_than: not_older_than
      ).call
    end
  end
end
