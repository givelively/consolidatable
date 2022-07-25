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
      consolidatable = find_consolidatable
      consolidatable = create_consolidatable if consolidatable.nil?
      consolidatable unless consolidatable.stale?(@not_older_than)
    end

    private

    def computed_value
      @computed_value ||= @owner.send(@computer)
    end

    def create_consolidatable
      @owner.consolidations.create(var_name: @var_name,
                                   var_type: @var_type,
                                   "#{@var_type}_value": computed_value)
    end

    def find_consolidatable
      @owner.consolidations.find_by(var_name: @var_name, var_type: @var_type)
    end
  end
end
