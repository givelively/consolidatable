# frozen_string_literal: true

require_relative 'configuration'
require_relative 'core'
require_relative 'filtering'
require_relative 'errors'

module Consolidatable
  module Base
    extend ActiveSupport::Concern

    included do
      include Configuration
      include Core
      include Filtering
    end
  end
end
