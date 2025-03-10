# frozen_string_literal: true

module Consolidatable
  class InlineFetcher < Fetcher
    def call
      warn "[DEPRECATION] `#{self.class}` is deprecated and will be removed in version 1.0. " \
           'Use Consolidatable::InlineStrategy instead.'

      InlineStrategy.new(
        owner: @owner,
        variable: @variable,
        computer: @computer,
        not_older_than: @not_older_than,
        write_wrapper: @write_wrapper
      ).fetch
    end
  end
end
