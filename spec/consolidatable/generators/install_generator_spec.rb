# frozen_string_literal: true

require 'generators/consolidatable/install_generator'

describe Consolidatable::Generators::InstallGenerator do
  let(:config_file) { './config/initializers/consolidatable.rb' }

  before { FileUtils.remove_file(config_file) if File.file?(config_file) }

  after { FileUtils.remove_file(config_file) if File.file?(config_file) }

  it 'installs config file properly' do
    described_class.start
    expect(File.file?(config_file)).to be true
  end
end
