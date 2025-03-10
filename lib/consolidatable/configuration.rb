# frozen_string_literal: true

module Consolidatable
  module Configuration
    extend ActiveSupport::Concern

    included do
      class_attribute :consolidate_methods, default: []
    end

    class_methods do
      def consolidations_config
        @consolidations_config ||= {}
      end

      private

      def configure_consolidation(as, type:, not_older_than:, fetcher:, write_wrapper:, computer:)
        consolidations_config[as] = {
          type: type,
          not_older_than: not_older_than,
          fetcher: fetcher,
          write_wrapper: write_wrapper,
          computer: computer
        }
      end
    end
  end
end
