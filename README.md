# Consolidatable

## Contributing
### Testing

Consolidatable uses rspec as testing framework.
you will have to create a database and configure the database connection (please see
spec/support/database.example.yml). The specs come with their own database schema (please see
spec/support/schema.rb)

run `bundle exec rspec` to run all tests.
run `bundle exec rspec --tag ~db_access` to skip tests that perform actual write operations as
part of the spec.
