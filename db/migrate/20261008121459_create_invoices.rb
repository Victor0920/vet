class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.string :invoice_id
      t.references :customer, null: false, foreign_key: true
      t.references :enterprise, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end
