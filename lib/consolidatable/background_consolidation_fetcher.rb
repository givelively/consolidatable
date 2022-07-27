# frozen_string_literal: true

module Consolidatable
  class BackgroundConsolidationFetcher < ConsolidationFetcher
    def call
      consolidation = detect_consolidation || find_consolidation

      if consolidation.blank? || consolidation.stale?(@not_older_than)
        Consolidatable::ConsolidationFetcherJob
          .perform_later(@owner.class.name,
                         @owner.id,
                         @var_name,
                         @var_type,
                         @computer)

        return Consolidation.new(consolidatable: @owner,
                                 var_name: @var_name,
                                 var_type: @var_type,
                                 value: nil)
      end

      consolidation
    end
  end
end
