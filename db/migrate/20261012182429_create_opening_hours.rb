class CreateOpeningHours < ActiveRecord::Migration[8.1]
  def change
    create_table :opening_hours do |t|
      t.references :store, null: false, foreign_key: true
      t.integer :weekday, null: false # Ruby's Date#wday: 0 = Sunday … 6 = Saturday
      t.string :opens_at, null: false # "HH:MM", like the calendar hours
      t.string :closes_at, null: false

      t.timestamps
    end
    add_index :opening_hours, %i[ store_id weekday ]
  end
end
