# frozen_string_literal: true

RSpec.describe Consolidatable do
  it 'has a version number' do
    expect(Consolidatable::VERSION).to be_present
  end

  describe 'A Consolidatable' do
    it 'has consolidations' do
      expect(Organization.new).to respond_to(:consolidations)
    end
  end

  describe 'consolidating a string' do
    it 'provides a method to retrieve the consolidated value' do
      expect(Organization.new).to respond_to(:longest_present_name)
    end

    context 'when accessing the class' do
      it 'provides a scope based on the name' do
        expect(Organization).to respond_to(:with_longest_present_name)
      end

      it 'provides a scope to include the consolidated values' do
        expect(Organization.with_longest_present_name.to_sql).to include('AS longest_present_name')
      end
    end

    context 'when there is no data' do
      it 'returns nil' do
        expect(Organization.create.longest_present_name).to be_nil
      end
    end
  end

  describe 'with minimal setup' do
    it 'provides a method with predicable name to access to the consolidated value' do
      expect(Organization.new).to respond_to(:consolidated_heaviest_present)
    end

    it 'picks a default type for the consolidation' do
      organization = Organization.create
      organization.presents.create(weight: 300)

      expect(organization.consolidated_heaviest_present).to be_a(Float)
    end
  end
end
