class ChangeSterilizedDefaultOnPets < ActiveRecord::Migration[8.1]
  def change
    change_column_default :pets, :sterilized, from: false, to: nil
  end
end
