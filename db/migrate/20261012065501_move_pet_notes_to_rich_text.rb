class MovePetNotesToRichText < ActiveRecord::Migration[8.1]
  class MigrationPet < ActiveRecord::Base
    self.table_name = "pets"
  end

  def up
    MigrationPet.where.not(notes: [ nil, "" ]).find_each do |pet|
      # simple_format escapes the text and turns line breaks into <p>/<br>
      ActionText::RichText.create!(record_type: "Pet", record_id: pet.id, name: "notes",
        body: ActionController::Base.helpers.simple_format(pet.notes))
    end
    remove_column :pets, :notes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
