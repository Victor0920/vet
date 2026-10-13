class AddResponseToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_column :feedbacks, :response, :text
    add_column :feedbacks, :responded_at, :datetime
  end
end
