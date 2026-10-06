class AddStoreToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_reference :appointments, :store, null: false, foreign_key: true
  end
end
