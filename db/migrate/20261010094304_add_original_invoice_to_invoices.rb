class AddOriginalInvoiceToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_reference :invoices, :original_invoice, null: true, foreign_key: { to_table: :invoices }
  end
end
