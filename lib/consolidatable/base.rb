# frozen_string_literal: true

module Consolidatable
  module Base
    def consolidates(computer, options = {})
      as = options[:as]&.id2name || "consolidated_#{computer}"
      type = options[:type] || Consolidatable.config.type
      not_older_than = options[:not_older_than] || Consolidatable.config.not_older_than
      fetcher = options[:fetcher] || Consolidatable.config.fetcher
      write_wrapper = options[:write_wrapper]

      @consolidate_methods ||= []
      @consolidate_methods << as

      @consolidations_config ||= {}
      @consolidations_config[as] = {
        type: type,
        not_older_than: not_older_than,
        fetcher: fetcher,
        write_wrapper: write_wrapper,
        computer: computer
      }

      setup_scopes(as, type)
      define_consolidation_method(as)
    end

    def where_consolidated(conditions)
      scope = all

      conditions.each do |field, value|
        unless @consolidate_methods&.include?(field.to_s)
          raise ArgumentError, "#{field} is not a consolidated field"
        end

        table_alias = Consolidatable::Consolidation.arel_table.alias("#{field}_alias")
        type = @consolidations_config[field.to_s][:type]
        var_name = table_alias[:var_name]
        type_value = table_alias["#{type}_value"]

        scope = scope.send(:"with_#{field}")
        scope = apply_conditions(scope, var_name, type_value, field, value)
      end

      scope
    end

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

    def setup_scopes(as, type)
      scope(
        :"with_#{as}",
        lambda do
          consolidatables_arel = arel_table
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
                    .and(consolidations_alias[:consolidatable_type].eq(name))
                    .and(consolidations_alias[:var_name].eq(as))
                    .and(consolidations_alias[:var_type].eq(type))
                )
                .join_sources
            )
        end
      )
    end

    def define_consolidation_method(as)
      config = @consolidations_config[as]

      define_method(as) do
        fetcher = config[:fetcher]
        type = config[:type]
        write_wrapper = config[:write_wrapper]
        computer = config[:computer]
        not_older_than = config[:not_older_than]

        value = fetcher.new(
          owner: self,
          variable: Variable.new(name: as, type: type),
          computer: computer,
          not_older_than: not_older_than,
          write_wrapper: write_wrapper
        ).call.value

        value
      end
    end

    def apply_conditions(scope, var_name, type_value, as, value)
      case value
      when Hash
        apply_operator_conditions(scope, var_name, type_value, as, value)
      else
        scope.where(var_name.eq(as)).where(type_value.eq(value))
      end
    end

    def apply_operator_conditions(scope, var_name, type_value, as, conditions)
      conditions.each do |operator, operand|
        scope = case operator.to_sym
                when :gt, :greater_than
                  scope.where(var_name.eq(as)).where(type_value.gt(operand))
                when :gte, :greater_than_or_equal_to
                  scope.where(var_name.eq(as)).where(type_value.gteq(operand))
                when :lt, :less_than
                  scope.where(var_name.eq(as)).where(type_value.lt(operand))
                when :lte, :less_than_or_equal_to
                  scope.where(var_name.eq(as)).where(type_value.lteq(operand))
                when :not_eq, :not_equal_to
                  scope.where(var_name.eq(as)).where.not(type_value.eq(operand))
                when :eq, :equal_to
                  scope.where(var_name.eq(as)).where(type_value.eq(operand))
                when :in
                  scope.where(var_name.eq(as)).where(type_value.in(operand))
                when :not_in
                  scope.where(var_name.eq(as)).where(type_value.not_in(operand))
                when :null
                  apply_null_condition(scope, var_name, type_value, as, operand)
                else
                  scope
                end
      end
      scope
    end

    def apply_null_condition(scope, var_name, type_value, as, want_null)
      if want_null
        scope.where(
          var_name.eq(nil).or(
            var_name.eq(as).and(type_value.eq(nil))
          )
        )
      else
        scope.where(var_name.eq(as)).where.not(type_value.eq(nil))
      end
    end
  end
end
