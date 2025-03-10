# frozen_string_literal: true

RSpec.describe Consolidatable::FetcherJob do
  subject(:perform) { job.perform(**params) }

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
  let(:fetcher) { Consolidatable::InlineFetcher }

  describe 'perform/perform_later' do
    before do
      allow(fetcher)
        .to receive(:new)
        .and_return(
          fetcher.new(owner: child,
                      variable: variable,
                      computer: :heaviest_present,
                      not_older_than: 1.day)
        )
    end

    it 'calls Consolidatable::InlineConsolidationFetcher' do
      perform
      expect(fetcher).to have_received(:new)
    end
  end
end
