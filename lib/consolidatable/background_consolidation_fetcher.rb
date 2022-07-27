# frozen_string_literal: true

module Consolidatable
  class BackgroundConsolidationFetcher < ConsolidationFetcher
    def call
      consolidation = detect_consolidation || find_consolidation

      schedule_job if consolidation.blank? || consolidation.stale?(@not_older_than)
      consolidation = build_new_consolidation if consolidation.blank?

      consolidation
    end

    private

    def build_new_consolidation
      Consolidation.new(
        consolidatable: @owner,
        var_name: @variable.name,
        var_type: @variable.type,
        value: nil
      )
    end

    def schedule_job
      Rails.logger.debug('In the fetcher')
      Rails.logger.debug(@owner.inspect)
      Rails.logger.debug(@variable.inspect)
      Rails.logger.debug(@computer.inspect)
      Rails.logger.debug(@not_older_than.inspect)

      Consolidatable::ConsolidationFetcherJob.perform_later(
        owner_class: @owner.class.name,
        owner_id: @owner.id,
        variable_hash: @variable.to_h,
        computer: @computer,
        not_older_than: @not_older_than
      )
    end
  end
end
