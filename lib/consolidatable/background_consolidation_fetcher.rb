# frozen_string_literal: true

module Consolidatable
  class BackgroundConsolidationFetcher < ConsolidationFetcher
    def call
      consolidation = detect_consolidation || find_consolidation

      if consolidation.blank? || consolidation.stale?(@not_older_than)
        Consolidatable::ConsolidationFetcherJob
          .perform_later(@owner.class.name,
                         @owner.id,
                         @variable.to_h,
                         @computer)

        return Consolidation.new(consolidatable: @owner,
                                 var_name: @variable.name,
                                 var_type: @variable.type,
                                 value: nil)
      end

      consolidation
    end
  end
end
