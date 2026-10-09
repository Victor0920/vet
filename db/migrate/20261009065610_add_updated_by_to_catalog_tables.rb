class AddUpdatedByToCatalogTables < ActiveRecord::Migration[8.1]
  def change
    %i[products product_categories services service_categories].each do |table|
      # The column is updated_by_id, but it points at employees, so to_table is needed.
      # on_delete: :nullify → deleting an employee clears the field instead of failing.
      add_reference table, :updated_by, foreign_key: { to_table: :employees, on_delete: :nullify }
    end
  end
end
