class RenameInvoiceIdToNumberOnInvoices < ActiveRecord::Migration[8.1]
  def change
    rename_column :invoices, :invoice_id, :number
  end
end
