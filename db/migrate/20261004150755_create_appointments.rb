class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.string :date

      t.timestamps
    end
  end
end
