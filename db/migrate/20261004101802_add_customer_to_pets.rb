class AddCustomerToPets < ActiveRecord::Migration[8.1]
  def change
    add_reference :pets, :customer, null: false, foreign_key: true
  end
end
