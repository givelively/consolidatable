# frozen_string_literal: true

module Consolidatable
  class InlineConsolidationFetcher < ConsolidationFetcher
    def call
      consolidation = detect_consolidation || find_consolidation
      consolidation = create_consolidation if consolidation.nil?
      consolidation.destale!(computed_value) if consolidation.stale?(@not_older_than)
      consolidation
    end

    private

    def create_consolidation
      @owner.consolidations.create(
        var_name: @var_name,
        var_type: @var_type,
        "#{@var_type}_value": computed_value
      )
    end
  end
end
