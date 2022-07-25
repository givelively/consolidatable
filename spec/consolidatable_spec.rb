# frozen_string_literal: true

# Basic classes for testing
class ApplicationRecord < ActiveRecord::Base
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

RSpec.shared_examples 'consolidates types' do |type, computer|
  let(:present) { class_double(Present).as_stubbed_const(transfer_nested_constants: true) }
  let(:type) { type }
  let(:computer) { computer }

  before do
    Child.send(:consolidates, computer, type: type)
  end

  it 'provides a method to retrieve the consolidated value' do
    expect(Child.new).to respond_to(computer)
  end

  context 'when accessing the class' do
    it 'provides a scope based on the name' do
      expect(Child).to respond_to(:"with_consolidated_#{computer}")
    end

    it 'provides a scope to include the consolidated values' do
      expect(Child.send(:"with_consolidated_#{computer}").to_sql)
        .to include("AS consolidated_#{computer}")
    end
  end

  context 'when there is no data' do
    it 'returns nil' do
      allow(present).to receive(computer).and_return(nil)
      expect(Child.new.send(computer)).to be_nil
    end
  end
end

RSpec.describe Consolidatable do
  let(:present) { class_double(Present).as_stubbed_const(transfer_nested_constants: true) }

  it 'has a version number' do
    expect(Consolidatable::VERSION).to be_a(String)
  end

  describe 'A Consolidatable' do
    it 'has consolidations' do
      expect(Child.new).to respond_to(:consolidations)
    end
  end

  context 'when consolidating a float value' do
    it_behaves_like 'consolidates types', :float, :heaviest_present
  end

  context 'when consolidating a string value' do
    it_behaves_like 'consolidates types', :string, :longest_present_name
  end

  context 'when consolidating a integer value' do
    it_behaves_like 'consolidates types', :integer, :avg_price
  end

  context 'when consolidating a boolean value' do
    it_behaves_like 'consolidates types', :boolean, :all_cute?
  end

  context 'when consolidating a datetime value' do
    it_behaves_like 'consolidates types', :datetime, :oldest_present
  end

  describe 'with minimal setup', db_access: true do
    before do
      Child.send(:consolidates, :heaviest_present)
    end

    it 'provides a method with predicable name to access to the consolidated value' do
      expect(Child.new).to respond_to(:consolidated_heaviest_present)
    end

    it 'picks a default type for the consolidation' do
      child = Child.create

      allow(present).to receive(:heaviest_present).and_return(300)
      expect(child.consolidated_heaviest_present).to be_a(Float)
    end

    it 'creates a new consolidation when called for the first time' do
      child = Child.create
      child.presents.create(weight: 300)

      expect { child.consolidated_heaviest_present }
        .to change(child.consolidations, :count)
        .from(0).to(1)
    end

    context 'with fresh consolidations' do
      it 'does not create a new consolidation when called' do
        child = Child.create
        child.presents.create(weight: 300)
        child.consolidated_heaviest_present

        expect { child.consolidated_heaviest_present }
          .not_to change(child.consolidations, :count)
      end
    end
  end
end
