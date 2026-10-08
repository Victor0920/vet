class AddColorToStores < ActiveRecord::Migration[8.1]
  def change
    add_column :stores, :color, :string
  end
end
