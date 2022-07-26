# frozen_string_literal: true

# Child and Present are setup in spec/support/basics.rb
RSpec.shared_examples 'consolidates types' do |type, computer|
  let(:present) do
    class_double(Present).as_stubbed_const(transfer_nested_constants: true)
  end
  let(:type) { type }
  let(:computer) { computer }

  before { Child.send(:consolidates, computer, type: type) }

  it 'provides a method to retrieve the consolidated value' do
    expect(Child.new).to respond_to(computer)
  end

  context 'when there is no data' do
    it 'returns nil' do
      allow(present).to receive(computer).and_return(nil)
      expect(Child.new.send(computer)).to be_nil
    end
  end
end

RSpec.describe Consolidatable do
  let(:present) do
    class_double(Present).as_stubbed_const(transfer_nested_constants: true)
  end

  it 'has a version number' do
    expect(Consolidatable::VERSION).to be_a(String)
  end

  describe 'A Consolidatable' do
    it 'has consolidations' do
      expect(Child.new).to respond_to(:consolidations)
    end
  end

  context 'when consolidating a float value' do
    it_behaves_like 'consolidates types', :float, :heaviest_present
  end

  context 'when consolidating a string value' do
    it_behaves_like 'consolidates types', :string, :longest_present_name
  end

  context 'when consolidating a integer value' do
    it_behaves_like 'consolidates types', :integer, :avg_price
  end

  context 'when consolidating a boolean value' do
    it_behaves_like 'consolidates types', :boolean, :all_cute?
  end

  context 'when consolidating a datetime value' do
    it_behaves_like 'consolidates types', :datetime, :oldest_present
  end

  describe 'with minimal setup' do
    before { Child.send(:consolidates, :heaviest_present) }

    it 'provides a method with predicable name to access to the consolidated value' do
      expect(Child.new).to respond_to(:consolidated_heaviest_present)
    end

    it 'picks a default type for the consolidation' do
      child = Child.create

      allow(present).to receive(:heaviest_present).and_return(300)
      expect(child.consolidated_heaviest_present).to be_a(Integer)
    end

    it 'creates a new consolidation when called for the first time' do
      child = Child.create
      child.presents.create(weight: 300)

      expect { child.consolidated_heaviest_present }.to change(
        child.consolidations,
        :count
      ).from(0).to(1)
    end

    context 'with fresh consolidations' do
      it 'does not create a new consolidation when called' do
        child = Child.create
        child.presents.create(weight: 300)
        child.consolidated_heaviest_present

        expect { child.consolidated_heaviest_present }.not_to change(
          child.consolidations,
          :count
        )
      end
    end
  end

  describe 'default config' do
    let(:fake_class) { class_double(described_class) }

    it 'allows to set the default timeout' do
      allow(fake_class).to receive(:not_older_than=).with(1.year)
      fake_class.not_older_than = 1.year
      expect(fake_class).to have_received(:not_older_than=).with(1.year)
    end

    it 'allows to set the default fetcher' do
      allow(fake_class).to receive(:fetcher=).with(
        Consolidatable::InlineFetcher
      )
      fake_class.fetcher = Consolidatable::InlineFetcher
      expect(fake_class).to have_received(:fetcher=).with(
        Consolidatable::InlineFetcher
      )
    end
  end
end
