# frozen_string_literal: true

require 'active_record'
require 'rails/railtie'

require 'consolidatable/base'
require 'consolidatable/class_extensions'
require 'consolidatable/configurable'
require 'consolidatable/configuration'
require 'consolidatable/consolidation'
require 'consolidatable/consolidation_fetcher'
require 'consolidatable/version'

module Consolidatable
  class << self
    attr_accessor :not_older_than
  end
end
