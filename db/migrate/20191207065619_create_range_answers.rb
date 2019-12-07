class CreateRangeAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :range_answers do |t|
      t.integer :question_id
      t.string :min_limit
      t.string :max_limit
      t.integer :follow_up_question
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
