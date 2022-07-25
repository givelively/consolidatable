# frozen_string_literal: true

RSpec.describe Consolidatable::Consolidation do
  it 'has a consolidatable' do
    expect(described_class.new).to respond_to(:consolidatable)
  end

  context 'when calling stale?' do
    subject(:stale?) do
      described_class.new(updated_at: updated_at).stale?(not_older_than)
    end

    context 'when being stale' do
      let(:updated_at) { DateTime.now - 3.days }
      let(:not_older_than) { DateTime.now - 2.days }

      it { is_expected.to be true }
    end

    context 'when not being stale' do
      let(:updated_at) { DateTime.now - 2.days }
      let(:not_older_than) { DateTime.now - 3.days }

      it { is_expected.to be false }
    end

    context 'when on the edge' do
      let(:updated_at) { DateTime.now - 2.days }
      let(:not_older_than) { updated_at }

      it { is_expected.to be false }
    end
  end

  context 'when calling value' do
    subject(:consolidation) do
      described_class.new(
        float_value: 17,
        integer_value: 42,
        boolean_value: true,
        string_value: 'seventeen point three',
        datetime_value: DateTime.now - 1.day,
        var_type: type
      )
    end

    context 'when asking for a boolean' do
      let(:type) { :boolean }

      it 'returns a boolean' do
        expect(consolidation.value).to be_a(TrueClass)
      end
    end

    context 'when asking for a String' do
      let(:type) { :string }

      it 'returns a string' do
        expect(consolidation.value).to be_a(String)
      end
    end

    context 'when asking for a DateTime' do
      let(:type) { :datetime }

      it 'returns a DateTime' do
        expect(consolidation.value).to be_a(DateTime)
      end
    end

    context 'when asking for an integer' do
      let(:type) { :integer }

      it 'returns a integer' do
        expect(consolidation.value).to be_a(Integer)
      end
    end

    context 'when asking for a float' do
      let(:type) { :float }

      it 'returns a float' do
        expect(consolidation.value).to be_a(Float)
      end
    end
  end
end
