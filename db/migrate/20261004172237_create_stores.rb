class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :address
      t.string :post_code
      t.references :enterprise, null: false, foreign_key: true

      t.timestamps
    end
  end
end
