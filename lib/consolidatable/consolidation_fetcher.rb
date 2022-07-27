# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcher
    def initialize(owner, variable:, computer:, not_older_than:)
      @owner = owner
      @variable = variable
      @computer = computer
      @not_older_than = not_older_than
    end

    def call
      raise NotImplementedError
    end

    private

    def computed_value
      @computed_value ||= @owner.send(@computer)
    end

    def detect_consolidation
      Consolidation.detect(@owner.consolidations, @variable)
    end

    def find_consolidation
      @owner.consolidations.find_variable(@variable).first
    end
  end
end
