# frozen_string_literal: true

module Consolidatable
  class ConsolidationFetcher
    def initialize(obj, var_name:, var_type:, calculator:, not_older_than:)
      @obj = obj
      @var_name = var_name
      @var_type = var_type
      @calculator = calculator
      @not_older_than = not_older_than
    end

    def call
      Consolidation.new
    end
  end
end
