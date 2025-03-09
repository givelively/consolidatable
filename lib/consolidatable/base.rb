# frozen_string_literal: true

module Consolidatable
  # rubocop:disable Metrics/ModuleLength
  module Base
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def consolidates(computer, options = {})
      as = options[:as]&.id2name || "consolidated_#{computer}"
      type = options[:type] || Consolidatable.config.type
      not_older_than = options[:not_older_than] || Consolidatable.config.not_older_than
      fetcher = options[:fetcher] || Consolidatable.config.fetcher
      write_wrapper = options[:write_wrapper]

      @@consolidate_methods ||= []
      @@consolidate_methods << as

      @consolidations_config ||= {}
      @consolidations_config[as] = {
        type: type,
        not_older_than: not_older_than,
        fetcher: fetcher,
        write_wrapper: write_wrapper,
        computer: computer
      }

      send(
        :scope,
        :"with_#{as}",
        (
          lambda do
            consolidatables_arel = klass.arel_table
            consolidations_alias =
              Consolidatable::Consolidation.arel_table.alias("#{as}_alias")

            select(consolidatables_arel[Arel.star])
              .select(consolidations_alias[:"#{type}_value"].as(as))
              .includes(:consolidations)
              .joins(
                consolidatables_arel
                  .join(consolidations_alias, Arel::Nodes::OuterJoin)
                  .on(
                    consolidations_alias[:consolidatable_id]
                      .eq(consolidatables_arel[:id])
                      .and(consolidations_alias[:consolidatable_type].eq(klass))
                      .and(consolidations_alias[:var_name].eq(as))
                      .and(consolidations_alias[:var_type].eq(type))
                  )
                  .join_sources
              )
          end
        )
      )

      define_method(as) do
        fetcher
          .new(
            owner: self,
            variable: Variable.new(name: as, type: type),
            computer: computer,
            not_older_than: not_older_than,
            write_wrapper: write_wrapper
          )
          .call
          .value
      end
    end

    def where_consolidated(conditions)
      scope = all

      conditions.each do |field, value|
        as = "consolidated_#{field}"
        table_alias = Consolidatable::Consolidation.arel_table.alias("#{as}_alias")
        type = consolidations_config[as][:type]

        # Join with the consolidation table if not already joined
        scope = scope.send(:"with_#{as}")

        case value
        when Hash
          value.each do |operator, operand|
            case operator.to_sym
            when :gt, :greater_than
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where(table_alias[:"#{type}_value"].gt(operand))
            when :gte, :greater_than_or_equal_to
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where(table_alias[:"#{type}_value"].gteq(operand))
            when :lt, :less_than
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where(table_alias[:"#{type}_value"].lt(operand))
            when :lte, :less_than_or_equal_to
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where(table_alias[:"#{type}_value"].lteq(operand))
            when :not_eq, :not_equal_to
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where.not(table_alias[:"#{type}_value"].eq(operand))
            when :eq, :equal_to
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where(table_alias[:"#{type}_value"].eq(operand))
            when :in
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where(table_alias[:"#{type}_value"].in(operand))
            when :not_in
              scope = scope.where(table_alias[:var_name].eq(as))
              scope = scope.where(table_alias[:"#{type}_value"].not_in(operand))
            when :null
              if operand
                # For null values, we either want no consolidation record or a null value
                scope = scope.where(
                  table_alias[:id].eq(nil).or(
                    table_alias[:var_name].eq(as).and(
                      table_alias[:"#{type}_value"].eq(nil)
                    )
                  )
                )
              else
                scope = scope.where(table_alias[:var_name].eq(as))
                scope = scope.where.not(table_alias[:"#{type}_value"].eq(nil))
              end
            end
          end
        else
          # Simple equality when just a value is provided
          scope = scope.where(table_alias[:var_name].eq(as))
          scope = scope.where(table_alias[:"#{type}_value"].eq(value))
        end
      end

      scope
    end

    # Convenience methods for common comparisons
    def where_consolidated_gt(field, value)
      where_consolidated(field => { gt: value })
    end

    def where_consolidated_gte(field, value)
      where_consolidated(field => { gte: value })
    end

    def where_consolidated_lt(field, value)
      where_consolidated(field => { lt: value })
    end

    def where_consolidated_lte(field, value)
      where_consolidated(field => { lte: value })
    end

    private

    def consolidations_config
      @consolidations_config ||= {}
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ModuleLength
end
