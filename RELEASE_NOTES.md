# Consolidatable v0.2.0

## New Features

### Lambda/Proc Support
Added support for using lambdas and procs as consolidation computers. This allows for inline value calculations without needing to define separate methods:

```ruby
class User
  include Consolidatable
  
  # Using a lambda with float type
  consolidates ->(user) { user.orders.sum(:amount) },
              as: :total_orders_amount,
              type: :float

  # Using a proc with boolean type
  consolidates proc { |user| user.comments.count > 10 },
              as: :frequent_commenter,
              type: :boolean
end
```

When using a lambda or proc:
- The `:as` option is required to specify the consolidation method name
- The callable receives the record instance as its argument
- Make sure to specify the appropriate `:type` for the returned value
- All other options (`:not_older_than`, `:fetcher`) work as normal

### Requirements
- Ruby 2.7 or higher
- Rails 6.0 or higher

### Migration from v0.1.0
This release is fully backward compatible. No changes are required to existing code.
