# frozen_string_literal: true

require 'active_record'
require 'database_cleaner'
require 'erb'
require 'yaml'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Organization < ApplicationRecord
  include Consolidatable

  has_many :presents

  def self.longest_name_calculator
    Present.longest_name_for(self)
  end
end

class Present < ApplicationRecord
  belongs_to :organization

  #   t.string 'name'
  #   t.float 'weight'
  #   t.integer 'price'
  #   t.boolean 'cute'
  #   t.datetime 'produced_at'
end
