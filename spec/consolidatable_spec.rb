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
    let(:present) { class_double(Present).as_stubbed_const(transfer_nested_constants: true) }

    before do
      Organization.send(:consolidates, :longest_present_name,
                        { as: :consolidated_present_name,
                          type: :string })
    end

    it 'provides a method to retrieve the consolidated value' do
      expect(Organization.new).to respond_to(:longest_present_name)
    end

    context 'when accessing the class' do
      it 'provides a scope based on the name' do
        expect(Organization).to respond_to(:with_consolidated_present_name)
      end

      it 'provides a scope to include the consolidated values' do
        expect(Organization.with_consolidated_present_name.to_sql)
          .to include('AS consolidated_present_name')
      end
    end

    context 'when there is no data' do
      it 'returns nil' do
        expect(present).to receive(:longest_name_for).and_return(nil)
        expect(Organization.new.longest_present_name).to be_nil
      end
    end
  end

  describe 'with minimal setup' do
    before do
      Organization.send(:consolidates, :heaviest_present)
    end

    it 'provides a method with predicable name to access to the consolidated value' do
      expect(Organization.new).to respond_to(:consolidated_heaviest_present)
    end

    it 'picks a default type for the consolidation' do
      organization = Organization.create
      organization.presents.create(weight: 300)

      expect(organization.consolidated_heaviest_present).to be_a(Float)
    end

    it 'creates a new consolidation when called for the first time' do
      organization = Organization.create
      organization.presents.create(weight: 300)

      expect { organization.consolidated_heaviest_present }
        .to change(organization.consolidations, :count)
        .from(0).to(1)
    end

    context 'with fresh consolidations' do
      it 'does not create a new consolidation when called' do
        organization = Organization.create
        organization.presents.create(weight: 300)
        organization.consolidated_heaviest_present

        expect { organization.consolidated_heaviest_present }
          .not_to change(organization.consolidations, :count)
      end
    end
  end
end
