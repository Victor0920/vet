
class CreatePetWeights < ActiveRecord::Migration[8.1]
  def change
    create_table :pet_weights do |t|
      t.references :pet, null: false, foreign_key: true
      t.decimal :weight, precision: 5, scale: 2, null: false
      t.date :measured_on, null: false

      t.timestamps
    end
    # One weighing per pet per day, enforced by the database too
    add_index :pet_weights, %i[ pet_id measured_on ], unique: true
  end
end
