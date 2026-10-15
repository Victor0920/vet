class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true # who took the money
      t.decimal :amount, precision: 9, scale: 2, null: false
      t.string :payment_method, null: false, default: "cash"
      t.datetime :paid_at, null: false
      t.timestamps
    end
  end
end
