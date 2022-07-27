# frozen_string_literal: true

module Consolidatable
  module Base
    def consolidates(computer, options = {})
      as = options[:as]&.id2name || "consolidated_#{computer}"
      type = options[:type] || :float
      not_older_than =
        options[:not_older_than] || Consolidatable.config.not_older_than
      fetcher = options[:fetcher] || Consolidatable.config.fetcher

      @@consolidate_methods ||= []
      @@consolidate_methods << as

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
          .new(owner: self,
               variable: Variable.new(name: as, type: type),
               computer: computer,
               not_older_than: not_older_than)
          .call
          .value
      end
    end
  end
end
