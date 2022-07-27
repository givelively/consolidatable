# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Consolidatable::BackgroundFetcher do
  subject(:call) { fetcher.call }

  let(:fetcher) do
    described_class.new(
      owner: owner,
      variable: variable,
      computer: computer,
      not_older_than: not_older_than
    )
  end
  let(:owner) { Child.create }
  let(:variable) do
    Variable.new(name: :consolidated_heaviest_present, type: :float)
  end
  let(:computer) { :heaviest_present }
  let(:not_older_than) { 1.day }
  let(:present) do
    class_double(Present).as_stubbed_const(transfer_nested_constants: true)
  end

  before { Child.send(:consolidates, computer, type: variable.type) }

  context 'when no matching Consolidation can be found' do
    before { allow(present).to receive(computer) }

    it_behaves_like 'returns a Consolidation'
    it 'does not call the computer' do
      call
      expect(present).not_to have_received(computer)
    end

    it 'does not create a new Consolidation' do
      expect { call }.not_to change(owner.consolidations, :count)
    end

    it 'returns a consolidation with nil as value' do
      expect(call.value).to be_nil
    end

    it 'schedules a background job to update the value' do
      allow(Consolidatable::FetcherJob).to receive(:perform_later)
      call
      expect(Consolidatable::FetcherJob).to have_received(
        :perform_later
      ).with(not_older_than: 1.day,
             computer: computer,
             owner_class: 'Child',
             owner_id: owner.id,
             variable_hash: variable.to_h)
    end
  end

  context 'when Consolidation is stale?' do
    let!(:consolidation) do
      owner.consolidations.create(
        var_name: variable.name,
        var_type: variable.type,
        float_value: 1,
        updated_at: 1.year.ago,
        created_at: 1.year.ago
      )
    end

    it_behaves_like 'returns a Consolidation'
    it 'does not touch the consolidation' do
      expect { call }.not_to(change { consolidation.reload.updated_at })
    end

    context 'with new data' do
      before { allow(present).to receive(computer).and_return(9.0) }

      it 'does not update the consolidation value' do
        call
        expect(owner.consolidations.last.reload.float_value).to eq(1.0)
      end

      it 'returns a consolidation with the old value' do
        expect(call.value).to be(1.0)
      end

      it 'schedules a background job to update the value' do
        allow(Consolidatable::FetcherJob).to receive(
          :perform_later
        )
        call
        expect(Consolidatable::FetcherJob).to have_received(
          :perform_later
        )
      end
    end
  end

  context 'when given an object with eager loaded Consolidations' do
    before { owner.send(variable.name) }

    it_behaves_like 'returns a Consolidation'
    it 'does not make any AR calls' do
      owner = Child.includes(:consolidations).first
      expect(log_queries { owner.send(variable.name) }).not_to include(
        'Consolidatable::Consolidation Load'
      )
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
