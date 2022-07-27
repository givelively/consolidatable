# frozen_string_literal: true

RSpec.describe Consolidatable::ConsolidationFetcherJob do
  subject(:perform) { job.perform }

  let(:job) { ConsolidationFetcherJob.new(params) }
  let(:params) { nil }

  describe 'perform/perform_later' do
    context 'with existing consolidation' do
      it 'updates the existing consolidation'
    end

    context 'without existing consolidation' do
      it 'creates a new consolidation'
    end
  end
end
