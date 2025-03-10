# frozen_string_literal: true

RSpec.describe Consolidatable do
  let(:present) do
    class_double(Present).as_stubbed_const(transfer_nested_constants: true)
  end

  before do
    Child.send(:consolidates, :avg_price)
    Child.send(:consolidates, :heaviest_present)
  end

  describe 'using the scope' do
    it 'provides a scope based on the name' do
      expect(Child).to respond_to(:with_consolidated_avg_price)
    end

    it 'provides a scope to include the consolidated values' do
      expect(Child.send(:with_consolidated_avg_price).to_sql).to include(
        'AS consolidated_avg_price'
      )
    end

    context 'with single scope' do
      let(:child1) { Child.create(name: 'child1') }
      let(:child2) { Child.create(name: 'child2') }

      before do
        allow(present).to receive(:avg_price).and_return(5.0)
        child1.consolidated_avg_price
        allow(present).to receive(:avg_price).and_return(2.0)
        child2.consolidated_avg_price
      end

      it 'calculates the avg_price for child1' do
        expect(child1.consolidated_avg_price).to eq(5.0)
      end

      it 'calculates the avg_price for child2' do
        expect(child2.consolidated_avg_price).to eq(2.0)
      end

      it 'allows to sort by consolidated values :asc' do
        children =
          Child.with_consolidated_avg_price.order(consolidated_avg_price: :asc)
        expect(children).to eq([child2, child1])
      end

      it 'allows to sort by consolidated values :desc' do
        children =
          Child.with_consolidated_avg_price.order(consolidated_avg_price: :desc)
        expect(children).to eq([child1, child2])
      end

      it 'allows to count(:all) with scope' do
        count =
          Child.with_consolidated_avg_price.count(:all)
        expect(count).to eq(2)
      end

      it 'does not skip a Child without consolidation' do
        Child.create(name: 'child3')
        expect(Child.with_consolidated_avg_price.size).to eq(3)
      end
    end

    context 'with two scopes' do
      let(:child1) { Child.create(name: 'child1') }
      let(:child2) { Child.create(name: 'child2') }
      let(:child3) { Child.create(name: 'child3') }

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

      it 'allows to sort by both scopes' do
        children = Child.with_consolidated_avg_price
                        .with_consolidated_heaviest_present
                        .order(consolidated_avg_price: :asc, consolidated_heaviest_present: :desc)

        # Should order first by avg_price (2.0, 5.0, 8.0)
        # Then by heaviest_present descending within same avg_price
        expect(children).to eq([child2, child1, child3])
      end

      it 'allows to sort by either scopes' do
        avg_price_sorted = Child.with_consolidated_avg_price
                                .with_consolidated_heaviest_present
                                .order(consolidated_avg_price: :asc)

        expect(avg_price_sorted).to eq([child2, child1, child3])

        weight_sorted = Child.with_consolidated_avg_price
                             .with_consolidated_heaviest_present
                             .order(consolidated_heaviest_present: :asc)

        expect(weight_sorted).to eq([child3, child1, child2])
      end

      it 'does not mix up the two consolidation tables' do
        # Verify that the values are correctly associated with each scope
        result = Child.with_consolidated_avg_price
                      .with_consolidated_heaviest_present
                      .find(child1.id)

        expect(result.consolidated_avg_price).to eq(5.0)
        expect(result.consolidated_heaviest_present).to eq(10.0)
      end
    end
  end
end
