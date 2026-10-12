class MakeConversationsUniquePerCustomer < ActiveRecord::Migration[8.1]
  def change
    remove_index :conversations, :customer_id
    add_index :conversations, :customer_id, unique: true
  end
end
