# frozen_string_literal: true

module Consolidatable
  module Strategies
    class InlineFetchStrategy < FetcherStrategy
      def execute_strategy
        consolidation = detect_consolidation || find_consolidation
        consolidation = create_consolidation(computed_value) if consolidation.nil?
        consolidation.destale!(computed_value) if consolidation.stale?(not_older_than)
        consolidation
      end
    end
  end
end

