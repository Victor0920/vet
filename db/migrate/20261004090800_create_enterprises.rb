class CreateEnterprises < ActiveRecord::Migration[8.1]
  def change
    create_table :enterprises do |t|
      t.string :name
      t.string :legal_name
      t.string :cif
      t.string :address

      t.timestamps
    end
  end
end
