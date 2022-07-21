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

  def longest_present_name
    Present.longest_name_for(self)
  end

  def heaviest_present
    Present.heaviest_for(self)
  end

  def avg_present_price
    Present.avg_price_for(self)
  end

  def all_cute?
    Present.all_cute?(self)
  end

  def oldest_present
    Present.oldest_present_for(self)
  end
end

class Present < ApplicationRecord
  belongs_to :organization

  def self.longest_name_for(obj); end
  def self.heaviest_for(obj)
    obj.presents.maximum(:weight)
  end
  def self.avh_price_for(obj); end
  def self.all_cute?(obj); end
  def self.oldest_present_for(obj); end
end
