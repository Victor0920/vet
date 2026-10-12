class ReplacePetsSpeciesWithReference < ActiveRecord::Migration[8.1]
  # Minimal copies of the models, so this migration keeps working even if
  # app/models changes later
  class MigrationPet < ActiveRecord::Base
    self.table_name = "pets"
  end

  class MigrationPetSpecies < ActiveRecord::Base
    self.table_name = "pet_species"
  end

  def up
    change_column_null :pet_species, :name, false
    add_index :pet_species, :name, unique: true
    add_reference :pets, :pet_species, foreign_key: true

    # Move existing text ("Dog", "Cat") to the new reference ("dog", "cat")
    MigrationPet.where.not(species: [ nil, "" ]).distinct.pluck(:species).each do |old_value|
      species = MigrationPetSpecies.find_or_create_by!(name: old_value.strip.downcase)
      MigrationPet.where(species: old_value).update_all(pet_species_id: species.id)
    end

    remove_column :pets, :species
  end

  def down
    add_column :pets, :species, :string
    execute <<~SQL
        UPDATE pets SET species = (SELECT name FROM pet_species WHERE pet_species.id = pets.pet_species_id)
      SQL
    remove_reference :pets, :pet_species, foreign_key: true
    remove_index :pet_species, :name
    change_column_null :pet_species, :name, true
  end
end
