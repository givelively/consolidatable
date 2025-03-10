# frozen_string_literal: true

module Consolidatable
  class BackgroundStrategy < FetcherStrategy
    def execute_strategy
      consolidation = detect_consolidation || find_consolidation

      schedule_background_job if consolidation.blank? || consolidation.stale?(not_older_than)
      consolidation = build_placeholder_consolidation if consolidation.blank?

      consolidation
    end

    private

    def build_placeholder_consolidation
      Consolidation.new(
        consolidatable: owner,
        var_name: variable.name,
        var_type: variable.type,
        value: nil
      )
    end

    def schedule_background_job
      Consolidatable::FetcherJob.perform_later(
        owner_class: owner.class.name,
        owner_id: owner.id,
        variable_hash: variable.to_h,
        computer: computer,
        not_older_than: not_older_than
      )
    end
  end
end
