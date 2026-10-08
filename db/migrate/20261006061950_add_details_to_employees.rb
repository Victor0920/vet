class AddDetailsToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :role, :string
    add_column :employees, :phone, :string
    add_column :employees, :active, :boolean
  end
end
