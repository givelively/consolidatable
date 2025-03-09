# frozen_string_literal: true

RSpec.describe Consolidatable do
  let(:present) do
    class_double(Present).as_stubbed_const(transfer_nested_constants: true)
  end

  before do
    Child.send(:consolidates, :avg_price)
    Child.send(:consolidates, :heaviest_present)
  end

  describe 'filtering consolidated values' do
    let!(:child1) { Child.create(name: 'child1') }
    let!(:child2) { Child.create(name: 'child2') }
    let!(:child3) { Child.create(name: 'child3') }
    let!(:child4) { Child.create(name: 'child4') }  # No consolidation values

    before do
      # Set up avg_price consolidations
      allow(present).to receive(:avg_price).and_return(5.0)
      child1.consolidated_avg_price
      allow(present).to receive(:avg_price).and_return(2.0)
      child2.consolidated_avg_price
      allow(present).to receive(:avg_price).and_return(8.0)
      child3.consolidated_avg_price

      # Set up heaviest_present consolidations
      allow(present).to receive(:heaviest_present).and_return(10.0)
      child1.consolidated_heaviest_present
      allow(present).to receive(:heaviest_present).and_return(15.0)
      child2.consolidated_heaviest_present
      allow(present).to receive(:heaviest_present).and_return(5.0)
      child3.consolidated_heaviest_present
    end

    context 'with simple equality' do
      it 'filters by exact value' do
        result = Child.where_consolidated(avg_price: 5.0)
        expect(result).to contain_exactly(child1)
      end
    end

    context 'with comparison operators' do
      it 'filters with greater than' do
        result = Child.where_consolidated(avg_price: { gt: 5.0 })
        expect(result).to contain_exactly(child3)
      end

      it 'filters with greater than or equal to' do
        result = Child.where_consolidated(avg_price: { gte: 5.0 })
        expect(result).to contain_exactly(child1, child3)
      end

      it 'filters with less than' do
        result = Child.where_consolidated(avg_price: { lt: 5.0 })
        expect(result).to contain_exactly(child2)
      end

      it 'filters with less than or equal to' do
        result = Child.where_consolidated(avg_price: { lte: 5.0 })
        expect(result).to contain_exactly(child1, child2)
      end
    end

    context 'with multiple fields' do
      it 'combines conditions for different fields' do
        result = Child.where_consolidated(
          avg_price: { gt: 2.0 },
          heaviest_present: { lt: 12.0 }
        )
        expect(result).to contain_exactly(child1)
      end
    end

    context 'with null values' do
      it 'filters for null values' do
        result = Child.where_consolidated(avg_price: { null: true })
        expect(result).to contain_exactly(child4)
      end

      it 'filters for non-null values' do
        result = Child.where_consolidated(avg_price: { null: false })
        expect(result).to contain_exactly(child1, child2, child3)
      end
    end

    context 'with convenience methods' do
      it 'provides shorthand for greater than' do
        result = Child.where_consolidated_gt(:avg_price, 5.0)
        expect(result).to contain_exactly(child3)
      end

      it 'provides shorthand for less than' do
        result = Child.where_consolidated_lt(:avg_price, 5.0)
        expect(result).to contain_exactly(child2)
      end
    end
  end
end

