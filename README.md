# Consolidatable

Consolodatable rovides tooling to precalculate values and keep them in the database for a specified time.

## Installation
This gem is unreleased and currently only available via
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

### Simple use case
```ruby
class Nonprofit
  includes Consolidatable
  consolidates :very_expensive_value

  def vey_expensive_value
    sleep(3)
    rand(10)
  end
end
```

The simplest use case above will provide a method `consolidated_very_expensive_value`.

By default, `consolidates` assumes that you want to store a `Float` value.

The first time you call `consolidated_very_expensive_value` will call `very_expensive_value` and cache the value.

The second time you call `consolidated_very_expensive_value`, you will be provided with the cached value.

### type
If you don't want to consolidate a Float value, you have to specify the type like this:
```ruby
class Nonprofit
  [...]
  consolidates :very_expensive_value, type: :integer
  [...]
end
```
Supported types are
- `:float` (default)
- `:integer`
- `:boolean`
- `:string`
- `:datetime`

### not_older_than

By default, cached values will be considered fresh for the time defined in `config/initializers/consolidatable.rb`, by default set to `1.hour`.

To overwrite that value, you can do this by specifying `not_older_than`:
```ruby
consolidates :very_expensive_value, not_older_than: 1.day
```

### as

Consolidatable provides a default name for the method returning the consolidated value by prefixing the original method name with `consolidated_`.
To change the name of that method use the `as` attribute (defining the method `cheap_value`):
```ruby
consolidates :very_expensive_value, as: :cheap_value
```

## Scope
By default, Consolidatable provides a scope named after the new value. Below example provides a scope `with_total_amount_raised`
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
The scope also eager loads the consolidations that belong to your class.

## Calculating the new value
Using the default `InlineConsolidationFetcher`, Consolidatable computes the requested value if the cache is stale or doesn't exist yet. In those cases **_Consolidatable will attempt to write to the database_**, Even though you are calling a getter.

There is an experimental[^experimental] fetcher called `BackgroundConsolidationFetcher` that provides the cached value or nil and not attempt to write to the database. Stale or nonexistent values will be refreshed in the background, by triggering an ActiveJob.

To change the fetcher, use
```ruby
consolidates :very_expensive_value, fetcher: BackgroundConsolidationFetcher
```
or change the default fetcher in `config/initializers/consolidatable.rb`.

[^experimental]: As in: the tests pass, but no one has tried it yet.

## Contributing

### Testing

Consolidatable uses rspec as testing framework.
you will have to create a database and configure the database connection (please see
spec/support/database.example.yml). The specs come with their own database schema (please see
spec/support/schema.rb)

run `bundle exec rspec` to run all tests.
