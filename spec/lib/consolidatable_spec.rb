# frozen_string_literal: true

describe Consolidatable do
  it 'is possible to provide config options' do
    described_class.config do |c|
      expect(c).to eq(described_class)
    end
  end
end
