class AddReadAtToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :read_at, :datetime
    add_index :messages, :read_at

    # Messages from before this column existed count as already read
    up_only { execute "UPDATE messages SET read_at = created_at" }
  end
end
