class AddCalendarHoursToEnterprises < ActiveRecord::Migration[8.1]
  def change
    # "HH:MM" strings: exactly what <input type="time"> sends and shows
    add_column :enterprises, :calendar_opens_at, :string, default: "08:00", null: false
    add_column :enterprises, :calendar_closes_at, :string, default: "20:00", null: false
    # Length of a new appointment: its end time starts as start + this many minutes
    add_column :enterprises, :default_appointment_minutes, :integer, default: 30, null: false
  end
end
