class AddEnterpriseToProductCategory < ActiveRecord::Migration[8.1]
  def up
    add_reference :product_categories, :enterprise, null: true, foreign_key: true

    execute <<~SQL
        UPDATE product_categories
        SET enterprise_id = (SELECT id FROM enterprises ORDER BY id LIMIT 1)
      SQL

    change_column_null :product_categories, :enterprise_id, false
       end

  def down
    remove_reference :product_categories, :enterprise, foreign_key: true
  end
end
