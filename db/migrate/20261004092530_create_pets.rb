class CreatePets < ActiveRecord::Migration[8.1]
  def change
    create_table :pets do |t|
      t.string :name
      t.string :species
      t.string :breed
      t.string :sex
      t.date :born_on
      t.string :notes
      t.string :color
      t.string :transponder_number
      t.string :transponder_location

      t.timestamps
    end
  end
end
