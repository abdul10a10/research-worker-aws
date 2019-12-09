class CreateRangeResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :range_responses do |t|
      t.integer :user_id
      t.integer :question_id
      t.float :description
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
