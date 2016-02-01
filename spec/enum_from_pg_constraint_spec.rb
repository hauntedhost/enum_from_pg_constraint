require 'spec_helper'

describe EnumFromPgConstraint do
  TABLE_NAME = :enum_from_pg_constraint_examples

  before(:context) do
    raise 'PostgreSQL database is required' unless database_is_postgresql?

    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Migration.create_table TABLE_NAME do |t|
        t.string :status, null: false, default: 'pending'
      end

      ActiveRecord::Migration.execute %{
        ALTER TABLE #{TABLE_NAME} ADD CONSTRAINT allowed_statuses
          CHECK (status IN (
            'pending', -- request has not been attempted
            'success', -- request succeeded
            'failure'  -- request failed
          ));
      }
    end
  end

  after(:context) do
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Migration.drop_table TABLE_NAME
    end
  end

  it 'has a version number' do
    expect(EnumFromPgConstraint::VERSION).not_to be nil
  end

  describe '.enum_from_pg_constraint' do
    before(:context) do
      class HappyPathExample < ActiveRecord::Base
        self.table_name = TABLE_NAME
        include EnumFromPgConstraint
        enum_from_pg_constraint :status
      end
    end

    subject(:model) { HappyPathExample }

    it 'defines status enum' do
      expect(model.defined_enums).to include('status')
    end

    it 'adds expected #statuses' do
      expected_statues = {
        'pending' => 'pending',
        'success' => 'success',
        'failure' => 'failure'
      }

      expect(model.statuses).to eq(expected_statues)
    end

    context 'given active_record has a non-pg adapter' do
      before(:example) do
        allow(ActiveRecord::Base).to receive(:connection)
          .and_return(OpenStruct.new(adapter_name: 'MySQL'))
      end

      before(:context) do
        class WrongAdapterExample < ActiveRecord::Base
          self.table_name = TABLE_NAME
          include EnumFromPgConstraint
        end
      end

      subject(:model) { WrongAdapterExample }

      it 'defines status enum' do
        expect {
          model.enum_from_pg_constraint :status
        }.to raise_error(EnumFromPgConstraintError)
      end
    end
  end

  private

  def database_is_postgresql?
    ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  end
end
