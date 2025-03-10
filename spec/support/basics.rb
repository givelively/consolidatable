# frozen_string_literal: true

require 'active_job'
require 'active_record'
require 'database_cleaner'
require 'erb'
require 'yaml'

# Basic classes for testing

class ::ApplicationJob < ActiveJob::Base
end

class ::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Child < ApplicationRecord
  include Consolidatable

  has_many :presents

  def longest_present_name
    Present.longest_present_name(self)
  end

  def heaviest_present
    Present.heaviest_present(self)
  end

  def avg_price
    Present.avg_price(self)
  end

  def all_cute?
    Present.all_cute?(self)
  end

  def oldest_present
    Present.oldest_present(self)
  end
end

class Present < ApplicationRecord
  belongs_to :child

  def self.longest_present_name(obj); end

  def self.heaviest_present(obj); end

  def self.avg_price(obj); end

  def self.all_cute?(obj); end

  def self.oldest_present(obj); end
end
