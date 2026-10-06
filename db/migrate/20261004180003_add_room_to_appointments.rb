class AddRoomToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_reference :appointments, :room, null: false, foreign_key: true
  end
end
