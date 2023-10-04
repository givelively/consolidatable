# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'spec/'
  add_filter '.github/'
  add_filter 'lib/generators/templates/'
  add_filter 'lib/consolidatable/version'
  add_filter 'lib/consolidatable/configurable'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
