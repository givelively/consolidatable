# frozen_string_literal: true

module Consolidatable
  module Core
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    class_methods do
      def consolidates(computer, options = {})
        type = options.fetch(:type, :float)
        as = options.fetch(:as, "consolidated_#{computer}")
        not_older_than = options.fetch(:not_older_than, nil)
        fetcher = options.fetch(:fetcher, computer)
        write_wrapper = options.fetch(:write_wrapper, nil)

        consolidate_methods << as
        configure_consolidation(as, type: type,
                                    not_older_than: not_older_than,
                                    fetcher: fetcher,
                                    write_wrapper: write_wrapper,
                                    computer: computer)

        setup_scopes(as)
        define_consolidation_method(as, computer, write_wrapper)
      end

      private

      def setup_scopes(as)
        scope(
          :"with_#{as}",
          lambda {
            joins(
              "LEFT OUTER JOIN consolidatable_consolidations AS #{as}_alias ON " \
              "#{as}_alias.consolidatable_type = '#{name}' AND " \
              "#{as}_alias.consolidatable_id = #{table_name}.id AND " \
              "#{as}_alias.var_name = '#{as}'"
            )
          }
        )
      end

      def define_consolidation_method(as, computer, write_wrapper)
        define_method(as) do
          config = self.class.consolidations_config[as]
          value = send(config[:fetcher])
          value = write_wrapper.call(value) if write_wrapper

          Consolidatable::Consolidation
            .write_value(
              consolidatable: self,
              var_name: as,
              type: config[:type],
              value: value,
              not_older_than: config[:not_older_than]
            )
            .value
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
