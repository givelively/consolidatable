# frozen_string_literal: true

RSpec.shared_examples 'returns a Consolidation' do
  subject(:call) { fetcher.call }

  it { is_expected.to be_a(Consolidatable::Consolidation) }
end

RSpec.describe Consolidatable::ConsolidationFetcher, db_access: true do
  subject(:call) { fetcher.call }

  let(:fetcher) do
    described_class.new(
      Child.create,
      var_name: :foo,
      var_type: :float,
      computer: :bar,
      not_older_than: 1.day
    )
  end

  before { Child.send(:consolidates, :bar, type: :float) }

  it 'raises an exception' do
    expect { call }.to raise_exception(NotImplementedError)
  end
end
