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

    # Add a deprecated warning when fetcher is set
    def fetcher=(value)
      warn "[DEPRECATION] `fetcher=` is deprecated and will be removed in version 1.0. " \
           "The fetcher classes will be replaced by strategy classes."
      @fetcher = value
    end

    # New method to get the appropriate strategy class
    def fetcher_strategy
      case fetcher
      when InlineFetcher, :inline
        InlineStrategy
      when BackgroundFetcher, :background
        BackgroundStrategy
      else
        fetcher
      end
    end
  end
end
