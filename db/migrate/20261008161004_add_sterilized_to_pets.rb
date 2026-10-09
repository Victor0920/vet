class AddSterilizedToPets < ActiveRecord::Migration[8.1]
  def change
    add_column :pets, :sterilized, :boolean, default: false
  end
end
