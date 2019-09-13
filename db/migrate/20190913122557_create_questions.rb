class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.integer :question_type
      t.integer :question_category
      t.string :title
      t.string :description
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
