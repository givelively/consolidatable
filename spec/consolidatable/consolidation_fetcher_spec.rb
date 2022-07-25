# frozen_string_literal: true

RSpec.shared_examples 'returns a Consolidation' do
  subject(:call) { fetcher.call }

  context 'when calling call' do
    it { is_expected.to be_a(Consolidatable::Consolidation) }
  end
end

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Consolidatable::ConsolidationFetcher, db_access: true do
  subject(:call) { fetcher.call }

  let(:fetcher) do
    described_class.new(obj, var_name: var_name,
                             var_type: var_type,
                             computer: computer,
                             not_older_than: not_older_than)
  end
  let(:obj) { Child.create }
  let(:var_name) { :consolidated_heaviest_present }
  let(:var_type) { :float }
  let(:computer) { :heaviest_present }
  let(:not_older_than) { 1.day }

  context 'when no matching Consolidation can be found' do
    let(:present) do
      class_double(Present)
        .as_stubbed_const(transfer_nested_constants: true)
    end

    before do
      allow(present).to receive(computer)
    end

    it_behaves_like 'returns a Consolidation'
    it 'calls the computer' do
      call
      expect(present)
        .to have_received(computer)
        .with(obj)
        .once
    end

    it 'creates a new Consolidation' do
      expect { call }
        .to change(obj.consolidations, :count)
        .from(0).to(1)
    end
  end

  context 'when Consolidation is stale?' do
    let(:consolidation) do
      obj.consolidations.create(var_name: var_name,
                                var_type: :float,
                                float_value: 4.2,
                                updated_at: 3.days.ago)
    end

    it_behaves_like 'returns a Consolidation'
    it 'touches the consolidation' do
      expect { call }.to change(consolidation, :updated_at)
    end

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
# rubocop:enable RSpec/MultipleMemoizedHelpers
