# frozen_string_literal: true

module Consolidatable
  def self.extended(model_class)
    return if model_class.respond_to? :consolidates

    model_class.class_eval do
      extend Base

      has_many :consolidations,
               class_name: '::Consolidatable::Consolidation',
               as: :consolidatable,
               dependent: :destroy
    end
  end

  def self.included(model_class)
    model_class.extend self
  end
end
