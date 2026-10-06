class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.decimal :price, precision: 7, scale: 2
      t.references :enterprise, null: false, foreign_key: true
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
