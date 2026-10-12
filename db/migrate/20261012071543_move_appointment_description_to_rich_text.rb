class MoveAppointmentDescriptionToRichText < ActiveRecord::Migration[8.1]
  class MigrationAppointment < ActiveRecord::Base
    self.table_name = "appointments"
  end

  def up
    MigrationAppointment.where.not(description: [ nil, "" ]).find_each do |appointment|
      # simple_format escapes the text and turns line breaks into <p>/<br>
      ActionText::RichText.create!(record_type: "Appointment", record_id: appointment.id, name: "description",
        body: ActionController::Base.helpers.simple_format(appointment.description))
    end
    remove_column :appointments, :description
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
