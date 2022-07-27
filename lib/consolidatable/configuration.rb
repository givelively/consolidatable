# frozen_string_literal: true

module Consolidatable
  include Configurable

  class Configuration
    attr_accessor :not_older_than,
                  :fetcher,
                  :type

    def initialize
      @not_older_than = 1.hour
      @type = :integer
      @fetcher = InlineFetcher
    end
  end
end
