class PrepareAppointmentsForCalendar < ActiveRecord::Migration[8.1]
  def change
    remove_column :appointments, :date, :string
    add_column :appointments, :starts_at, :datetime, null: false
    add_column :appointments, :ends_at, :datetime, null: false
    add_index :appointments, [ :room_id, :starts_at ]

    change_column_null :appointments, :customer_id, true
    change_column_null :appointments, :pet_id, true
  end
end
