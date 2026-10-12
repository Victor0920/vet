class DropUsers < ActiveRecord::Migration[8.1]
  def change
    drop_table :users do |t|
      t.string :name
      t.string :phone
      t.timestamps
    end
  end
end
