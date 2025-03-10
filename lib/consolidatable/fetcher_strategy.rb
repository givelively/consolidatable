# frozen_string_literal: true

module Consolidatable
  class FetcherStrategy
    def initialize(owner:, variable:, computer:, not_older_than:, write_wrapper: nil)
      @owner = owner
      @variable = variable
      @computer = computer
      @not_older_than = not_older_than
      @write_wrapper = write_wrapper || ->(&block) { block.call }
    end

    # Public interface that handles the wrapper
    def fetch
      write_wrapper.call do
        execute_strategy
      end
    end

    # Interface method that concrete strategies must implement
    def execute_strategy
      raise NotImplementedError, "#{self.class} must implement #execute_strategy"
    end

    protected

    attr_reader :owner, :variable, :computer, :not_older_than, :write_wrapper

    def computed_value
      @computed_value ||= owner.send(computer)
    end

    def detect_consolidation
      Consolidation.detect(owner.consolidations, variable)
    end

    def find_consolidation
      owner.consolidations.find_variable(variable).first
    end

    def create_consolidation(value)
      owner.consolidations.create(
        var_name: variable.name,
        var_type: variable.type,
        "#{variable.type}_value": value
      )
    end
  end
end
