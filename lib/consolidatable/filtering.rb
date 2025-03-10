# frozen_string_literal: true

module Consolidatable
  module Filtering
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    class_methods do
      def where_consolidated(conditions)
        scope = all

        conditions.each do |field, value|
          as = "consolidated_#{field}"
          raise ArgumentError, "#{field} is not a consolidated field" unless consolidate_methods.include?(as)

          table_alias = Consolidatable::Consolidation.arel_table.alias("#{as}_alias")
          type = consolidations_config[as][:type]
          var_name = table_alias[:var_name]
          type_value = table_alias["#{type}_value"]

          scope = scope.send(:"with_#{as}")
          scope = apply_conditions(scope, var_name, type_value, as, value)
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

      def apply_conditions(scope, var_name, type_value, as, value)
        case value
        when Hash
          apply_operator_conditions(scope, var_name, type_value, as, value)
        else
          apply_equality_condition(scope, var_name, type_value, as, value)
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

      def apply_equality_condition(scope, var_name, type_value, as, value)
        scope.where(var_name.eq(as)).where(type_value.eq(value))
      end

      def apply_null_condition(scope, var_name, type_value, as, want_null)
        if want_null
          scope.where(
            table_alias[:id].eq(nil).or(
              var_name.eq(as).and(type_value.eq(nil))
            )
          )
        else
          scope.where(var_name.eq(as)).where.not(type_value.eq(nil))
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
