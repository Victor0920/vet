class AddColorToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :color, :string
  end
end
