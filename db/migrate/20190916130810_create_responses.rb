class CreateResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :responses do |t|
      t.integer :user_id
      t.integer :question_id
      t.integer :answer_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
