# frozen_string_literal: true

RSpec.describe Consolidatable do
  let(:present) do
    class_double(Present).as_stubbed_constant(transfer_nested_constants: true)
  end

  describe 'lambda consolidation' do
    context 'with lambda as computer' do
      let(:example_lambda) { ->(record) { record.name.length } }

      it 'requires the :as option' do
        expect do
          Child.send(:consolidates, example_lambda)
        end.to raise_error(ArgumentError,
                           'The :as option is required when computer is a callable object')
      end

      it 'accepts lambda with :as option' do
        expect do
          Child.send(:consolidates, example_lambda, as: :name_length)
        end.not_to raise_error
      end

      it 'properly stores and executes the lambda' do
        Child.send(:consolidates, example_lambda, as: :name_length, type: :integer)
        child = Child.create(name: 'test_name')

        expect(child.name_length).to eq(9)
      end
    end

    context 'with invalid computers' do
      it 'rejects non-callable, non-symbol/string computers' do
        expect do
          Child.send(:consolidates, 123)
        end.to raise_error(ArgumentError,
                           'computer must be a method name (Symbol/String) or a callable object (lambda/proc)')
      end
    end

    context 'with method name (backwards compatibility)' do
      it 'still works with method names without :as option' do
        expect do
          Child.send(:consolidates, :heaviest_present)
        end.not_to raise_error
      end

      it 'generates the correct default name for method computers' do
        Child.send(:consolidates, :heaviest_present)
        expect(Child.new).to respond_to(:consolidated_heaviest_present)
      end
    end

    context 'with proc objects' do
      let(:example_proc) { proc { |record| record.name.upcase } }

      it 'accepts proc with :as option' do
        expect do
          Child.send(:consolidates, example_proc, as: :uppercase_name)
        end.not_to raise_error
      end

      it 'properly executes the proc' do
        Child.send(:consolidates, example_proc, as: :uppercase_name, type: :string)
        child = Child.create(name: 'test_name')

        expect(child.uppercase_name).to eq('TEST_NAME')
      end
    end
  end

  context 'with different return types' do
    it 'handles string values' do
      str_proc = proc { |record| record.name.upcase }
      Child.send(:consolidates, str_proc, as: :upper_name, type: :string)
      child = Child.create(name: 'test')
      expect(child.upper_name).to eq('TEST')
    end

    it 'handles integer values' do
      int_proc = proc { |record| record.name.length }
      Child.send(:consolidates, int_proc, as: :name_length, type: :integer)
      child = Child.create(name: 'test')
      expect(child.name_length).to eq(4)
    end

    it 'handles float values' do
      float_proc = proc { |record| record.name.length * 1.5 }
      Child.send(:consolidates, float_proc, as: :weighted_length, type: :float)
      child = Child.create(name: 'test')
      expect(child.weighted_length).to eq(6.0)
    end

    it 'handles boolean values' do
      bool_proc = proc { |record| record.name.length > 5 }
      Child.send(:consolidates, bool_proc, as: :long_name, type: :boolean)
      child = Child.create(name: 'test')
      expect(child.long_name).to be false
    end
  end
end
