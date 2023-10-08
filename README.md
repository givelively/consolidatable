# Consolidatable

Consolidatable provides tooling to precalculate values and cache them in the database for a specified amount of time.

## Installation

Add the following line to your Gemfile:

```ruby
gem 'consolidatable', git: 'https://github.com/givelively/consolidatable.git'
```

Download and install the gem:
```sh
bundle install
```

Generate the migration and initializer required by Consolidatable:
```sh
bundle exec rails g consolidatable:install
```

Migrate the database:
```sh
bundle exec rails db:migrate
```

## Interface

### Basic use case
```ruby
class Nonprofit
  include Consolidatable
  consolidates :very_expensive_value

  def very_expensive_value
    sleep(3)
    rand(10)
  end
end
```

The simplest use case above will provide a method named `consolidated_very_expensive_value`.

By default, `consolidates` assumes that you want to store a `Integer` value.

The first time you call `consolidated_very_expensive_value` it will call `very_expensive_value` and cache the value.

The second time you call `consolidated_very_expensive_value` it returns the cached value.

### type
If you don't want to consolidate an Integer value, you have to specify the type like this:
```ruby
class Nonprofit
  [...]
  consolidates :very_expensive_value, type: :float
  [...]
end
```
Supported types are
- `:float`
- `:integer` (default, stored as bigint)
- `:boolean`
- `:string`
- `:datetime`

Or you can change the default type in `config/initializers/consolidatable.rb`.
### not_older_than

By default, cached values will be considered fresh for the time defined in `config/initializers/consolidatable.rb`, by default set to `1.hour`.

To overwrite that value, you can do this by specifying `not_older_than`:
```ruby
consolidates :very_expensive_value, not_older_than: 1.day
```

### as

Consolidatable provides a default name for the method returning the consolidated value by prefixing the original method name with `consolidated_`.
To change the name of that method use the `as` attribute (defining the method `cheap_value` below):
```ruby
consolidates :very_expensive_value, as: :cheap_value
```

## Scope
By default, Consolidatable provides a scope named after the new value. Below example provides the scope `with_total_amount_raised`
```ruby
  consolidates :calculate_total_amount_raised, as: :total_amount_raised
```
The provided scope will add an aditional artificial column named after the new value:

```ruby
Nonprofit
  .with_total_amount_raised
  .order(total_amount_raised: :desc)
  .limit(5)
```

Will provide you the five nonprofits with the highest (cached) values for `total_amount_raised`.

If you need to `.count` the query, you must use `.count(:all)`.

## Calculating the new value
Using the default `InlineFetcher`, Consolidatable computes the requested value if the cache is stale or doesn't exist yet. In those cases **_Consolidatable will attempt to write to the database_**, even though you are calling a getter.

## Contributing

### Setup

1. `bundle install`
1. `RAILS_ENV=test bundle exec rake db:create db:schema:load`

### Testing

`bundle exec rspec`
