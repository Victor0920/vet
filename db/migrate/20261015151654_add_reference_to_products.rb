class AddReferenceToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :reference, :string
    # Two products of the same clinic can't share a reference. Products without one store NULL,
    # and NULLs never clash in a unique index, so any number of products can leave it blank
    add_index :products, [ :enterprise_id, :reference ], unique: true
  end
end
