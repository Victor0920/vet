class RemoveUpdatesStockFromInvoices < ActiveRecord::Migration[8.1]
  def change
    remove_column :invoices, :updates_stock, :boolean, default: true, null: false
  end
end
