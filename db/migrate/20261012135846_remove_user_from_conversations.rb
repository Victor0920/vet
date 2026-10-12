class RemoveUserFromConversations < ActiveRecord::Migration[8.1]
  def change
    remove_reference :conversations, :user, null: false, foreign_key: true
  end
end
