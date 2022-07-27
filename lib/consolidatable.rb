# frozen_string_literal: true

require 'active_record'
require 'active_job'
require 'rails/railtie'

require 'consolidatable/base'
require 'consolidatable/class_extensions'
require 'consolidatable/configurable'
require 'consolidatable/configuration'
require 'consolidatable/consolidation'
require 'consolidatable/fetcher'
require 'consolidatable/inline_fetcher'
require 'consolidatable/background_fetcher'
require 'consolidatable/jobs/fetcher_job'
require 'consolidatable/variable'
require 'consolidatable/version'

module Consolidatable
  class << self
    attr_accessor :not_older_than, :fetcher
  end
end
