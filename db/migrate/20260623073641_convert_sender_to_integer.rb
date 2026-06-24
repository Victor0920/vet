class ConvertSenderToInteger < ActiveRecord::Migration[8.1]
  def change
    # Convert existing string values to integers
    execute <<-SQL
      UPDATE messages SET sender = CASE
        WHEN sender = 'user' THEN 0
        WHEN sender = 'bot' THEN 1
        WHEN sender = 'admin' THEN 2
      END
    SQL

    # Change the column type from string to integer
    change_column :messages, :sender, :integer
  end
end
