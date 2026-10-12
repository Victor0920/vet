class AddUsualVetToPets < ActiveRecord::Migration[8.1]
  def change
    add_reference :pets, :usual_employee, null: true, foreign_key: { to_table: :employees }
  end
end
