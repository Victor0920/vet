class AddServiceToInvoiceProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :invoice_products, :service, foreign_key: true
  end
end
