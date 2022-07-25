# frozen_string_literal: true

RSpec.describe Consolidatable do
  let(:present) { class_double(Present).as_stubbed_const(transfer_nested_constants: true) }

  before { Child.send(:consolidates, :avg_price) }

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
        children = Child.with_consolidated_avg_price.order(consolidated_avg_price: :asc)
        expect(children).to eq([child2, child1])
      end

      it 'allows to sort by consolidated values :desc' do
        children = Child.with_consolidated_avg_price.order(consolidated_avg_price: :desc)
        expect(children).to eq([child1, child2])
      end

      it 'does not skip a Child without consolidation' do
        Child.create(name: 'child3')
        expect(Child.with_consolidated_avg_price.size).to eq(3)
      end
    end

    context 'with two scopes' do
      it 'allows to sort by both scopes'
      it 'allows to sort by either scopes'
      it 'allows to sort by all scopes'
      it 'does not mix up the two consolidation tables'
    end
  end
end
