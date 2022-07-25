# frozen_string_literal: true

RSpec.shared_examples 'returns a Consolidation' do
  subject(:call) { fetcher.call }

  it { is_expected.to be_a(Consolidatable::Consolidation) }
end

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Consolidatable::ConsolidationFetcher, db_access: true do
  subject(:call) { fetcher.call }

  let(:fetcher) do
    described_class.new(
      owner,
      var_name: var_name,
      var_type: var_type,
      computer: computer,
      not_older_than: not_older_than
    )
  end
  let(:owner) { Child.create }
  let(:var_name) { :consolidated_heaviest_present }
  let(:var_type) { :float }
  let(:computer) { :heaviest_present }
  let(:not_older_than) { 1.day.ago }
  let(:present) do
    class_double(Present).as_stubbed_const(transfer_nested_constants: true)
  end

  before { Child.send(:consolidates, computer, type: var_type) }

  context 'when no matching Consolidation can be found' do
    before { allow(present).to receive(computer) }

    it_behaves_like 'returns a Consolidation'
    it 'calls the computer' do
      call
      expect(present).to have_received(computer).with(owner).once
    end

    it 'creates a new Consolidation' do
      expect { call }.to change(owner.consolidations, :count).from(0).to(1)
    end
  end

  context 'when Consolidation is stale?' do
    let(:consolidation) do
      owner.consolidations.create(
        var_name: var_name,
        var_type: :float,
        float_value: 1,
        updated_at: 3.days.ago
      )
    end

    it_behaves_like 'returns a Consolidation'
    it 'touches the consolidation' do
      expect { call }.to(change { consolidation.reload.updated_at })
    end

    context 'with new data' do
      before { allow(present).to receive(computer).and_return(9.0) }

      it_behaves_like 'returns a Consolidation'
      it 'updates the consolidation value' do
        expect(call.value).to eq(9.0)
      end
    end
  end

  context 'when given an object with eager loaded Consolidations' do
    before { owner.send(var_name) }

    it_behaves_like 'returns a Consolidation'
    it 'does not make any AR calls' do
      owner = Child.includes(:consolidations).first
      expect(log_queries { owner.send(var_name) }).not_to include(
        'Consolidatable::Consolidation Load'
      )
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
