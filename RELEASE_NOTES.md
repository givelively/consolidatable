# Consolidatable v0.1.0

First public release of Consolidatable, a Ruby gem for precalculating and caching values in the database.

## Features

### Core Functionality
- Precalculate and cache values in the database
- Configurable cache duration
- Support for multiple data types (integer, float, boolean, string, datetime)
- Custom method naming
- Scoping capabilities for queries
- Flexible filtering API

### New in 0.1.0
- Lambda/Proc Support: Compute consolidated values using inline lambdas or procs
- Comprehensive filtering API with comparison operators
- Background job processing option
- Type safety improvements

## Installation

Add to your Gemfile:
```ruby
gem 'consolidatable'
```

## Migration from pre-0.1.0

If you were using the gem from git, update your Gemfile:

```ruby
# Before
gem 'consolidatable', git: 'https://github.com/givelively/consolidatable.git'

# After
gem 'consolidatable', '~> 0.1.0'
```

No other changes are required - all existing functionality remains backward compatible.
