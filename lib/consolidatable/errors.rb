# frozen_string_literal: true

module Consolidatable
  class Error < StandardError; end
  class InvalidFieldError < Error; end
  class InvalidOperatorError < Error; end
end
