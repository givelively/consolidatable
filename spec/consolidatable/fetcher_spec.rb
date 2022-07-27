# frozen_string_literal: true

RSpec.describe Consolidatable::Fetcher do
  subject(:call) { fetcher.call }

  let(:fetcher) do
    described_class
      .new(owner: nil, variable: nil, computer: nil, not_older_than: nil)
  end

  before { Child.send(:consolidates, :bar, type: :float) }

  it 'raises an exception' do
    expect { call }.to raise_exception(NotImplementedError)
  end
end
