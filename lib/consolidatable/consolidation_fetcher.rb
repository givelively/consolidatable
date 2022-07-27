# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcher
    def initialize(owner, var_name:, var_type:, computer:, not_older_than:)
      @owner = owner
      @var_name = var_name
      @var_type = var_type
      @computer = computer
      @not_older_than = not_older_than
      @variable = Variable.new(name: var_name, type: var_type)
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
      @owner.consolidations.find_by(var_name: @variable.name, var_type: @variable.type)
    end
  end
end
