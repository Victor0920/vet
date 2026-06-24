class AddSenderToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :sender, :string
  end
end
