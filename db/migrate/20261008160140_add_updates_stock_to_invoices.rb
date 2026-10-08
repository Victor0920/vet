class AddUpdatesStockToInvoices < ActiveRecord::Migration[8.1]
  def change
    # Invoices made before this feature never took anything out of stock
    add_column :invoices, :updates_stock, :boolean, default: false, null: false
    # New invoices do, unless the switch is turned off
    change_column_default :invoices, :updates_stock, from: false, to: true
  end
end
