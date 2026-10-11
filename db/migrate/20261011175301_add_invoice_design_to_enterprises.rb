class AddInvoiceDesignToEnterprises < ActiveRecord::Migration[8.1]
  def change
    add_column :enterprises, :invoice_layout, :string, default: "classic", null: false
    add_column :enterprises, :invoice_color, :string, default: "teal", null: false
    add_column :enterprises, :invoice_footer, :text
  end
end
