class AddLocaleToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :locale, :string, null: false, default: "es"
  end
end
