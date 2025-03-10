# frozen_string_literal: true

require 'active_record'
require 'active_job'
require 'rails/railtie'

require 'active_support'
require 'active_support/core_ext'

require 'consolidatable/version'
require 'consolidatable/configurable'
require 'consolidatable/configuration'
require 'consolidatable/consolidation'
require 'consolidatable/variable'

# Load base strategy first
require 'consolidatable/fetcher_strategy'

# Load concrete strategies
require 'consolidatable/strategies/inline_strategy'
require 'consolidatable/strategies/background_strategy'

# Load legacy fetcher classes
require 'consolidatable/fetcher'
require 'consolidatable/inline_fetcher'
require 'consolidatable/background_fetcher'

# Load remaining files
require 'consolidatable/base'
require 'consolidatable/jobs/fetcher_job'

module Consolidatable
  class << self
    attr_accessor :not_older_than, :fetcher
  end

  def self.included(model_class)
    model_class.extend self
  end

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
end
