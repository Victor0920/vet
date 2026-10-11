class AddLoginCodesToEnterprisesAndEmployees < ActiveRecord::Migration[8.1]
  def up
    add_column :enterprises, :login_code, :string
    add_column :employees, :username, :string

    # Existing rows need a value before the columns can be NOT NULL; admins can change them afterwards
    execute "UPDATE enterprises SET login_code = 'empresa' || id"
    execute "UPDATE employees SET username = 'empleado' || id"

    change_column_null :enterprises, :login_code, false
    change_column_null :employees, :username, false
    add_index :enterprises, :login_code, unique: true
    add_index :employees, [ :enterprise_id, :username ], unique: true

    # active: nil meant "active" so far; make that explicit (4th argument fills in the NULLs)
    change_column_default :employees, :active, from: nil, to: true
    change_column_null :employees, :active, false, true

    # Email is just contact info now: optional, and not unique across companies
    remove_index :employees, :email_address
    change_column_null :employees, :email_address, true
  end

  def down
    add_index :employees, :email_address, unique: true
    change_column_null :employees, :active, true
    change_column_default :employees, :active, from: true, to: nil
    remove_index :employees, [ :enterprise_id, :username ]
    remove_index :enterprises, :login_code
    remove_column :employees, :username
    remove_column :enterprises, :login_code
  end
end
