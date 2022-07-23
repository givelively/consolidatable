# frozen_string_literal: true

RSpec.shared_examples 'returns a Consolidation' do
  subject(:call) { fetcher.call }

  context 'when calling call' do
    it { is_expected.to be_a(Consolidatable::Consolidation) }
  end
end

RSpec.describe Consolidatable::ConsolidationFetcher do
  let(:fetcher) do
    described_class.new(obj, var_name: var_name,
                             var_type: var_type,
                             calculator: calculator,
                             not_older_than: not_older_than)
  end
  let(:obj) { Consolidatable::Consolidation.new }
  let(:var_name) { nil }
  let(:var_type) { nil }
  let(:calculator) { nil }
  let(:not_older_than) { nil }

  context 'when no Consolidation can be found' do
    it 'calls the calculator'
    it 'createds a new Consolidation'
    it_behaves_like 'returns a Consolidation'
  end

  context 'when Consolidation was stale?' do
    it 'touches the consolidation'
    it_behaves_like 'returns a Consolidation'

    context 'with new data' do
      it 'updates the consolidation value'
      it_behaves_like 'returns a Consolidation'
    end
  end

  context 'when given an object with eager loaded Consolidations' do
    it 'does not make any AR calls'
    it_behaves_like 'returns a Consolidation'
  end
end
