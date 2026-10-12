class AddDefaultStoreToEmployees < ActiveRecord::Migration[8.1]
  def change
    # Optional; points to stores (the column name doesn't match the table, hence to_table)
    add_reference :employees, :default_store, foreign_key: { to_table: :stores }
  end
end
