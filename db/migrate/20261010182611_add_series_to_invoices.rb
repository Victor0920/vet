class AddSeriesToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_column :invoices, :series, :string
    add_column :invoices, :sequence_number, :integer
    add_index :invoices, [ :enterprise_id, :series, :sequence_number ], unique: true
  end
end
