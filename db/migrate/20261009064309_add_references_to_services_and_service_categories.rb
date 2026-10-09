class AddReferencesToServicesAndServiceCategories < ActiveRecord::Migration[8.1]
  def change
    add_reference :service_categories, :enterprise, null: false, foreign_key: true
    add_reference :services, :service_category, null: false, foreign_key: true
  end
end
