class AddNameToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :first_name, :string
    add_column :employees, :last_name, :string
  end
end
