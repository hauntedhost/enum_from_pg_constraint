$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'enum_from_pg_constraint'
require 'active_record'
require 'active_support/core_ext/hash'

def establish_connection!(config)
  ActiveRecord::Base.establish_connection(config)
  ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError
  ActiveRecord::Base.establish_connection(config.except(:database))
  ActiveRecord::Base.connection.create_database(config[:database])
end

establish_connection!(
  adapter:  'postgresql',
  database: 'enum_from_pg_constraint_test',
  host:     'localhost'
)
