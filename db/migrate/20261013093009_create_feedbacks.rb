class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.references :employee, foreign_key: true # nullable: the feedback stays if the employee is deleted
      t.string :kind, null: false, default: "problem"
      t.text :message, null: false
      t.string :status, null: false, default: "received"
      t.string :page_url   # where they were when they opened the help page
      t.string :user_agent # their browser

      t.timestamps
    end
    add_index :feedbacks, %i[ status created_at ] # the inbox filters by status, newest first
  end
end
