# frozen_string_literal: true

RSpec.describe Consolidatable do
  let(:present) do
    class_double(Present).as_stubbed_const(transfer_nested_constants: true)
  end

  before do
    Child.send(:consolidates, :avg_price, as: :the_avg_price)
    Child.send(:consolidates, :heaviest_present, as: :the_heaviest_present)
  end

  describe 'filtering consolidated values' do
    let!(:child1) { Child.create(name: 'child1') }
    let!(:child2) { Child.create(name: 'child2') }
    let!(:child3) { Child.create(name: 'child3') }
    let!(:child4) { Child.create(name: 'child4') } # No consolidation values

    before do
      # Set up avg_price consolidations
      allow(present).to receive(:avg_price).and_return(5.0)
      child1.the_avg_price
      allow(present).to receive(:avg_price).and_return(2.0)
      child2.the_avg_price
      allow(present).to receive(:avg_price).and_return(8.0)
      child3.the_avg_price

      # Set up heaviest_present consolidations
      allow(present).to receive(:heaviest_present).and_return(10.0)
      child1.the_heaviest_present
      allow(present).to receive(:heaviest_present).and_return(15.0)
      child2.the_heaviest_present
      allow(present).to receive(:heaviest_present).and_return(13.0)
      child3.the_heaviest_present
    end

    context 'with simple equality' do
      it 'filters by exact value' do
        result = Child.where_consolidated(the_avg_price: 5.0)
        expect(result).to contain_exactly(child1)
      end
    end

    context 'with comparison operators' do
      it 'filters with greater than' do
        result = Child.where_consolidated(the_avg_price: { gt: 5.0 })
        expect(result).to contain_exactly(child3)
      end

      it 'filters with greater than or equal to' do
        result = Child.where_consolidated(the_avg_price: { gte: 5.0 })
        expect(result).to contain_exactly(child1, child3)
      end

      it 'filters with less than' do
        result = Child.where_consolidated(the_avg_price: { lt: 5.0 })
        expect(result).to contain_exactly(child2)
      end

      it 'filters with less than or equal to' do
        result = Child.where_consolidated(the_avg_price: { lte: 5.0 })
        expect(result).to contain_exactly(child1, child2)
      end
    end

    context 'with multiple fields' do
      it 'combines conditions for different fields' do
        result = Child.where_consolidated(
          the_avg_price: { gt: 2.0 },
          the_heaviest_present: { lt: 12.0 }
        )
        expect(result).to contain_exactly(child1)
      end
    end

    context 'with null values' do
      it 'filters for null values' do
        result = Child.where_consolidated(the_avg_price: { null: true })
        expect(result).to contain_exactly(child4)
      end

      it 'filters for non-null values' do
        result = Child.where_consolidated(the_avg_price: { null: false })
        expect(result).to contain_exactly(child1, child2, child3)
      end
    end

    context 'with convenience methods' do
      it 'provides shorthand for greater than' do
        result = Child.where_consolidated_gt(:the_avg_price, 5.0)
        expect(result).to contain_exactly(child3)
      end

      it 'provides shorthand for less than' do
        result = Child.where_consolidated_lt(:the_avg_price, 5.0)
        expect(result).to contain_exactly(child2)
      end
    end

    context 'with count-related queries' do
      before do
        Child.send(:consolidates, :discounted_presents_count, as: :discount_count)
        allow(present).to receive(:discounted_presents_count).and_return(5)
      end

      it 'handles actual COUNT queries' do
        expect do
          Child.where_consolidated(discount_count: { gt: 3 }).count
        end.not_to raise_error
      end

      it 'properly handles columns with "count" in the name' do
        # This should include the column in the SELECT clause
        query = Child.where_consolidated(discount_count: { gt: 3 })
        expect(query.to_sql).to include('AS discount_count')
      end

      it 'distinguishes between COUNT queries and count-named columns' do
        # Mock the calculating_count? method to verify its logic
        counter = 0
        allow_any_instance_of(Child.singleton_class).to receive(:calculating_count?) do
          counter += 1
          counter == 1 # True for the COUNT query, false for the regular select
        end

        # Should trigger calculating_count? = true
        Child.where_consolidated(discount_count: { gt: 3 }).count

        # Should trigger calculating_count? = false
        Child.where_consolidated(discount_count: { gt: 3 }).to_a

        expect(counter).to eq(2)
      end
    end
  end
end
