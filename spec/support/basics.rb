# frozen_string_literal: true

require 'active_record'
require 'database_cleaner'
require 'erb'
require 'yaml'

class Organization < ActiveRecord::Base
  include Consolidatable

  has_many :presents

  consolidates :longest_present_name_calculator, as: :longest_present_name, type: :string
  def longest_present_name_calculator
    presents.all.map(&:name).sort(&:length).first
  end

  consolidates :heaviest_present
  def heaviest_present
    presents.maximum(:weight)
  end

  #   t.float 'weight'
  #   t.integer 'price'
  #   t.boolean 'cute'
  #   t.datetime 'produced_at'
end

class Present < ActiveRecord::Base
  belongs_to :organization
end
