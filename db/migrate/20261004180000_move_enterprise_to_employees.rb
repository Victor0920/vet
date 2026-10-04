class MoveEnterpriseToEmployees < ActiveRecord::Migration[8.1]
  def up
    add_reference :employees, :enterprise, foreign_key: true

    # Keep each employee's first enterprise; fall back to the first enterprise if they had none
    execute <<~SQL
      UPDATE employees
      SET enterprise_id = COALESCE(
        (SELECT MIN(enterprise_id) FROM employments WHERE employments.employee_id = employees.id),
        (SELECT MIN(id) FROM enterprises)
      )
    SQL

    change_column_null :employees, :enterprise_id, false

    drop_table :employments
  end

  def down
    create_table :employments do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :enterprise, null: false, foreign_key: true

      t.timestamps
    end

    add_index :employments, [ :employee_id, :enterprise_id ], unique: true

    execute <<~SQL
      INSERT INTO employments (employee_id, enterprise_id, created_at, updated_at)
      SELECT id, enterprise_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM employees
    SQL

    remove_reference :employees, :enterprise, foreign_key: true
  end
end
