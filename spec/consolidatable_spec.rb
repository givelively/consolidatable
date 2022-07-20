# frozen_string_literal: true

RSpec.describe Consolidatable do
  it 'has consolidations' do
    expect(Organization.new).to respond_to(:consolidations)
  end
end
