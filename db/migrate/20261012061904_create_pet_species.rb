class CreatePetSpecies < ActiveRecord::Migration[8.1]
  def change
    create_table :pet_species do |t|
      t.timestamps
      t.string :name
    end
  end
end
