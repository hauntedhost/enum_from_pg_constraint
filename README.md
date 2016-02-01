## EnumFromPgConstraint

Derive a Rails [enum](http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html) from an existing PostgreSQL constraint.

## Usage:

Given a migration to create table `Thing` with a PostgreSQL constraint:

```ruby
class CreateThing < ActiveRecord::Migration
  def up
    create_table :things do |t|
      t.string :name
      t.string :status, null: false, default: 'pending'
      t.timestamps null: false
    end

    execute <<-SQL.strip_heredoc
      ALTER TABLE things
      ADD CONSTRAINT allowed_statuses
      CHECK (status IN (
        'pending', -- thing not yet attempted
        'success', -- thing succeeded
        'failure'  -- thing failed
      ));
    SQL
  end

  def down
    drop_table :things
  end
end
```

Add the constraint to your Model:

```ruby
class Thing < ActiveRecord::Base
  include EnumFromPgConstraint

  enum_from_pg_constraint :status
end
```

```ruby
$ rails c
> Thing.statuses
=> {"pending"=>"pending", "success"=>"success", "failure"=>"failure"}

> Thing.create(name: 'Hello World!')
> Thing.pending
=> [#<Thing:0x007fec93d6b5f0
  id: 1,
  name: 'Hello World!'
  status: "pending",
  created_at: Sun, 31 Jan 2016 18:53:25 PST -08:00,
  updated_at: Sun, 31 Jan 2016 18:53:25 PST -08:00>]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/somlor/enum_from_pg_constraint. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
