class AddCustomerToConversations < ActiveRecord::Migration[8.1]
  def up
    add_reference :conversations, :customer, null: true, foreign_key: true

    execute <<~SQL
        UPDATE conversations
        SET customer_id = (SELECT id FROM customers ORDER BY id LIMIT 1)
      SQL

    change_column_null :conversations, :customer_id, false
       end

  def down
    add_reference :conversations, :customer, null: false, foreign_key: true
  end
end
