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
      Consolidatable::ConsolidationFetcherJob.perform_later(
        @owner.class.name,
        @owner.id,
        @variable.to_h,
        @computer,
        @not_older_than
      )
    end
  end
end
