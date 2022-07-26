# frozen_string_literal: true

module Consolidatable
  module Configurable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def configuration
        @configuration ||= self::Configuration.new
      end
      alias config configuration

      def configure
        yield(configuration)
      end
    end
  end
end
