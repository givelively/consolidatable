# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcher
    def initialize(owner, var_name:, var_type:, computer:, not_older_than:)
      @owner = owner
      @var_name = var_name
      @var_type = var_type
      @computer = computer
      @not_older_than = not_older_than
    end

    def call
      consolidation = detect_consolidation || find_consolidation
      consolidation = create_consolidation if consolidation.nil?
      consolidation.destale!(computed_value) if consolidation.stale?(@not_older_than)
      consolidation
    end

    private

    def computed_value
      @computed_value ||= @owner.send(@computer)
    end

    def create_consolidation
      @owner.consolidations.create(
        var_name: @var_name,
        var_type: @var_type,
        "#{@var_type}_value": computed_value
      )
    end

    def detect_consolidation
      @owner.consolidations.detect do |c|
        c.var_name == @var_name && c.var_type.to_sym == @var_type
      end
    end

    def find_consolidation
      @owner.consolidations.find_by(var_name: @var_name, var_type: @var_type)
    end
  end
end
