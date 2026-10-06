class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :first_surname
      t.string :second_surname
      t.string :document_number
      t.string :document_type
      t.string :sex
      t.date :born_on
      t.string :address
      t.string :post_code
      t.string :province
      t.string :first_phone
      t.string :second_phone
      t.string :email

      t.timestamps
    end
  end
end
