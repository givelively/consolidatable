# frozen_string_literal: true

require File.expand_path('lib/consolidatable/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'consolidatable'
  spec.version = Consolidatable::VERSION
  spec.authors = ['Give Lively']
  spec.summary = 'Consolidate and Cache'
  spec.homepage = 'https://github.com/givelively/consolidatable'
  spec.license = 'MIT'
  spec.platform = Gem::Platform::RUBY

  spec.required_ruby_version = '>= 2.7.5'
  spec.extra_rdoc_files = ['README.md']
  spec.files =
    Dir[
      'README.md',
      'LICENSE',
      'CHANGELOG.md',
      'lib/**/*.rb',
      'lib/**/*.rake',
      'consolidatable.gemspec',
      '.github/*.md',
      'Gemfile',
      'Rakefile'
    ]
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 3.2.0'
  spec.add_dependency 'activesupport', '>= 3.2.0'
  spec.add_dependency 'railties', '>= 3.2.0'

  spec.add_development_dependency 'codecov', '~> 0.1'
  spec.add_development_dependency 'database_cleaner', '~> 2.0.1'
  spec.add_development_dependency 'factory_bot', '~> 6.2.1'
  spec.add_development_dependency 'pg', '~> 1.4.1'
  spec.add_development_dependency 'prettier', '~> 3.1.2'
  spec.add_development_dependency 'rails', '~> 6.0.5.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'rspec-rails', '~> 5.1.2'
  spec.add_development_dependency 'rubocop', '~> 1.30'
  spec.add_development_dependency 'rubocop-performance', '~> 1.14'
  spec.add_development_dependency 'rubocop-rails', '~> 2.15.2'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.12'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
