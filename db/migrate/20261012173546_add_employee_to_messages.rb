class AddEmployeeToMessages < ActiveRecord::Migration[8.1]
  def up
    # Nullable: customer messages (and the old ones) have no employee
    add_reference :messages, :employee, foreign_key: true

    # Old senders → new ones: user (0) stays 0 = customer, bot (1) stays 1 = employee,
    # admin (2) becomes 1 = employee
    execute "UPDATE messages SET sender = 1 WHERE sender = 2"
  end

  def down
    remove_reference :messages, :employee, foreign_key: true
  end
end
