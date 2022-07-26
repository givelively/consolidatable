# frozen_string_literal: true

module Consolidatable
  include Configurable

  class Configuration
    attr_accessor :not_older_than

    def initialize
      @not_older_than = 1.day
    end
  end
end
