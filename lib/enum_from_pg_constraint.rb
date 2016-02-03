require 'enum_from_pg_constraint/version'
require 'active_support/concern'

class EnumFromPgConstraintError < StandardError; end

module EnumFromPgConstraint
  extend ActiveSupport::Concern

  class_methods do
    def enum_from_pg_constraint(enum_name, constraint_name = nil)
      unless (adapter_name = connection.adapter_name) == 'PostgreSQL'
        raise EnumFromPgConstraintError,
          "unexpected database adapter. 'PostgreSQL' required, found: #{adapter_name.inspect}"
      end

      constraint_name ||= "allowed_#{enum_name.to_s.pluralize}"

      sql = <<-SQL.strip_heredoc
        SELECT consrc
        AS #{constraint_name}
        FROM pg_constraint
        WHERE conrelid = '#{table_name}'::regclass
        AND conname = '#{constraint_name}';
      SQL

      result = connection.execute(sql)
      constraint = result.entries.first[constraint_name]
      values = constraint.scan(/'([^']*)'/).flatten

      if values.none?
        raise EnumFromPgConstraintError,
          "no values found for constraint #{constraint_name.inspect}"
      end

      enum(enum_name.to_sym => Hash[values.zip(values)])
    end
  end
end
