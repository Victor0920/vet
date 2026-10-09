class AddUniqueIndexToInvoicesNumber < ActiveRecord::Migration[8.1]
  def change
    add_index :invoices, [ :enterprise_id, :invoice_id ], unique: true
  end
end
