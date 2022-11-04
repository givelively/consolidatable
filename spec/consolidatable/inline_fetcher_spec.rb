# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Consolidatable::InlineFetcher do
  subject(:call) { fetcher.call }

  let(:fetcher) do
    described_class.new(
      owner: owner,
      variable: variable,
      computer: computer,
      not_older_than: not_older_than,
      write_wrapper: write_wrapper
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
  let(:write_wrapper) { nil }

  before { Child.send(:consolidates, computer, type: variable.type) }

  shared_examples 'write wrapper logic' do
    context 'when write wrapper is present' do
      let(:test) { double }
      let(:write_wrapper) do
        lambda { |&block|
          test.invoked
          block.call
        }
      end

      before { allow(test).to receive(:invoked) }

      it_behaves_like 'returns a Consolidation'

      it 'calls the write wrapper' do
        call

        expect(test).to have_received(:invoked).once
      end
    end
  end

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

    include_examples 'write wrapper logic'
  end

  context 'when Consolidation is stale?' do
    let!(:consolidation) do
      owner.consolidations.create(
        var_name: variable.name,
        var_type: variable.type,
        float_value: 1,
        updated_at: 3.days.ago,
        created_at: 3.days.ago
      )
    end

    it_behaves_like 'returns a Consolidation'
    it 'touches the consolidation' do
      expect { call }.to(change { consolidation.reload.updated_at })
    end

    include_examples 'write wrapper logic'

    context 'with new data' do
      before { allow(present).to receive(computer).and_return(9.0) }

      include_examples 'write wrapper logic'

      it_behaves_like 'returns a Consolidation'
      it 'updates the consolidation value' do
        call
        expect(owner.consolidations.last.reload.float_value).to eq(9.0)
      end

      it 'returns a consolidation with the correct value' do
        expect(call.value).to eq(9.0)
      end
    end
  end

  context 'when given an object with eager loaded Consolidations' do
    before { owner.send(variable.name) }

    it_behaves_like 'returns a Consolidation'
    include_examples 'write wrapper logic'

    it 'does not make any AR calls' do
      owner = Child.includes(:consolidations).first
      expect(log_queries { owner.send(variable.name) }).not_to include(
        'Consolidatable::Consolidation Load'
      )
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
