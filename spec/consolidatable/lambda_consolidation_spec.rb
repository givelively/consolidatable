# frozen_string_literal: true

RSpec.describe Consolidatable do
  let(:present) do
    class_double(Present).as_stubbed_constant(transfer_nested_constants: true)
  end

  describe 'lambda consolidation' do
    context 'with lambda as computer' do
      let(:example_lambda) { ->(record) { record.name.length } }

      it 'requires the :as option' do
        expect {
          Child.send(:consolidates, example_lambda)
        }.to raise_error(ArgumentError, 'The :as option is required when computer is a callable object')
      end

      it 'accepts lambda with :as option' do
        expect {
          Child.send(:consolidates, example_lambda, as: :name_length)
        }.not_to raise_error
      end

      it 'properly stores and executes the lambda' do
        Child.send(:consolidates, example_lambda, as: :name_length)
        child = Child.create(name: 'test_name')

        expect(child.name_length).to eq(9)
      end
    end

    context 'with invalid computers' do
      it 'rejects non-callable, non-symbol/string computers' do
        expect {
          Child.send(:consolidates, 123)
        }.to raise_error(ArgumentError, 'computer must be a method name (Symbol/String) or a callable object (lambda/proc)')
      end
    end

    context 'with method name (backwards compatibility)' do
      it 'still works with method names without :as option' do
        expect {
          Child.send(:consolidates, :heaviest_present)
        }.not_to raise_error
      end

      it 'generates the correct default name for method computers' do
        Child.send(:consolidates, :heaviest_present)
        expect(Child.new).to respond_to(:consolidated_heaviest_present)
      end
    end

    context 'with proc objects' do
      let(:example_proc) { proc { |record| record.name.upcase } }

      it 'accepts proc with :as option' do
        expect {
          Child.send(:consolidates, example_proc, as: :uppercase_name)
        }.not_to raise_error
      end

      it 'properly executes the proc' do
        Child.send(:consolidates, example_proc, as: :uppercase_name)
        child = Child.create(name: 'test_name')

        expect(child.uppercase_name).to eq('TEST_NAME')
      end
    end
  end
end
