# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcherJob < ::ActiveJob::Base
    def perform(owner_class:, owner_id:, variable_hash:, computer:, not_older_than:)
      owner = owner_class.constantize.find(owner_id)
      variable = Variable.factory(variable_hash)

      Rails.logger.debug('In the job')
      Rails.logger.debug(owner.inspect)
      Rails.logger.debug(variable.inspect)
      Rails.logger.debug(computer.inspect)
      Rails.logger.debug(not_older_than.inspect)

      Consolidatable::InlineConsolidationFetcher.new(
        owner: owner,
        variable: variable,
        computer: computer,
        not_older_than: not_older_than
      ).call
    end
  end
end
