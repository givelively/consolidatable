# frozen_string_literal: true

RSpec.shared_examples 'returns a Consolidation' do
  subject(:call) { fetcher.call }

  it { is_expected.to be_a(Consolidatable::Consolidation) }
end
