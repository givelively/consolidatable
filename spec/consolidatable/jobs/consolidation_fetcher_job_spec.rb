# frozen_string_literal: true

RSpec.describe Consolidatable::ConsolidationFetcherJob do
  subject(:perform) { job.perform(params) }

  let(:job) { described_class.new }
  let(:child) { Child.create }
  let(:params) do
    { owner_class: 'Child',
      owner_id: child.id,
      variable_hash: variable.to_h,
      computer: :heaviest_present,
      not_older_than: 1.day }
  end
  let(:variable) { Variable.new(name: :foo, type: :float) }

  describe 'perform/perform_later' do
    before do
      allow(Consolidatable::InlineConsolidationFetcher)
        .to receive(:new)
        .and_return(Consolidatable::InlineConsolidationFetcher
        .new(owner: child, variable: variable, computer: :heaviest_present, not_older_than: 1.day))
    end

    it 'calls Consolidatable::InlineConsolidationFetcher' do
      perform
      expect(Consolidatable::InlineConsolidationFetcher).to have_received(:new)
    end

    context 'with existing consolidation' do
      it 'updates the existing consolidation'
    end

    context 'without existing consolidation' do
      it 'creates a new consolidation'
    end
  end
end
