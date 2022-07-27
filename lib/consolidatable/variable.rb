# frozen_string_literal: true

class Variable
  attr_reader :name, :type

  def self.factory(var_hash)
    Variable.new(name: var_hash[:name], type: var_hash[:type])
  end

  def initialize(name:, type:)
    @name = name
    @type = type
  end

  def to_h
    { name: @name, type: @type }
  end
end
