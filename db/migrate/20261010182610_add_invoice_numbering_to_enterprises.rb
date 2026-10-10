class AddInvoiceNumberingToEnterprises < ActiveRecord::Migration[8.1]
  def change
    add_column :enterprises, :invoice_number_schema, :string, null: false, default: "[y]/[n]"
    add_column :enterprises, :rectification_number_schema, :string
    add_column :enterprises, :invoice_counter_reset, :string, null: false, default: "yearly"
  end
end
