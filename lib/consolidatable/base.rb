# frozen_string_literal: true

module Consolidatable
  module Base
    def consolidates(computer, options = {})
      as             = options[:as]&.id2name || "consolidated_#{computer}"
      type           = options[:type] || :float
      not_older_than = Time.current - (options[:max_age] || 1.day)

      @@consolidate_methods ||= []
      @@consolidate_methods << as

      send(:scope,
           :"with_#{as}",
           (lambda do
             consolidatables_arel = klass.arel_table
             consolidations_alias = Consolidatable::Consolidation.arel_table.alias("#{as}_alias")

             select(consolidatables_arel[Arel.star])
               .select(consolidations_alias[:"#{type}_value"].as(as))
               .includes(:consolidations)
               .joins(
                 consolidatables_arel
                   .join(consolidations_alias, Arel::Nodes::OuterJoin)
                   .on(
                     consolidations_alias[:consolidatable_id].eq(consolidatables_arel[:id])
                       .and(consolidations_alias[:consolidatable_type].eq(klass))
                       .and(consolidations_alias[:var_name].eq(as))
                       .and(consolidations_alias[:var_type].eq(type))
                   )
                   .join_sources
               )
           end))

      define_method(as) do
        Consolidatable::ConsolidationFetcher.new(self, var_name: as,
                                                       var_type: type,
                                                       computer: computer,
                                                       not_older_than: not_older_than)
                                            .call
                                            .value
      end
    end
  end
end
