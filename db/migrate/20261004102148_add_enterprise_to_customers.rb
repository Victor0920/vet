class AddEnterpriseToCustomers < ActiveRecord::Migration[8.1]
  def up
    add_reference :customers, :enterprise, null: true, foreign_key: true

    execute <<~SQL
        UPDATE customers
        SET enterprise_id = (SELECT id FROM enterprises ORDER BY id LIMIT 1)
      SQL

    change_column_null :customers, :enterprise_id, false
     end

  def down
    remove_reference :customers, :enterprise, foreign_key: true
  end
end
