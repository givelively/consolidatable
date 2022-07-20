# frozen_string_literal: true

require 'active_record'
require 'database_cleaner'
require 'erb'
require 'yaml'

class Organization < ActiveRecord::Base
  include Consolidatable
end
