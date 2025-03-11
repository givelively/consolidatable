# frozen_string_literal: true

require File.expand_path('lib/consolidatable/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'consolidatable'
  spec.version = Consolidatable::VERSION
  spec.authors = ['Give Lively', 'Tim Lawrenz', 'GitHub Copilot / Claude 3.5 Sonnet']
  spec.summary = 'Consolidate and cache ActiveRecord calculations'
  spec.description = 'Consolidatable provides tooling to precalculate values and cache them in the database for a specified amount of time. Supports both method-based and lambda/proc-based calculations with type safety.'
  spec.homepage = 'https://github.com/givelively/consolidatable'
  spec.license = 'MIT'
  spec.platform = Gem::Platform::RUBY
  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'changelog_uri' => 'https://github.com/givelively/consolidatable/blob/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/givelively/consolidatable',
    'bug_tracker_uri' => 'https://github.com/givelively/consolidatable/issues',
    'last_updated' => '2025-03-11 01:22:56 UTC'
  }

  spec.required_ruby_version = '>= 3.2.0'
  spec.extra_rdoc_files = ['README.md']
  spec.files =
    Dir[
      'README.md',
      'LICENSE',
      'CHANGELOG.md',
      'lib/**/*.rb',
      'lib/**/*.erb',
      'lib/**/*.rake',
      'consolidatable.gemspec',
      '.github/*.md',
      'Gemfile',
      'Rakefile'
    ]
  spec.require_paths = ['lib']

  spec.add_dependency 'activejob', '>= 7.1.0'
  spec.add_dependency 'activerecord', '>= 7.1.0'
  spec.add_dependency 'activesupport', '>= 7.1.0'
  spec.add_dependency 'railties', '>= 7.1.0'
end
