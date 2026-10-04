class CreateEmployments < ActiveRecord::Migration[8.1]
  def change
    create_table :employments do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :enterprise, null: false, foreign_key: true

      t.timestamps
    end

    add_index :employments, [ :employee_id, :enterprise_id ], unique: true
  end
end
