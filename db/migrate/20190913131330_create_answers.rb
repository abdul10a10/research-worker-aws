class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.integer :question_id
      t.string :description
      t.integer :follow_up_question
      t.timestamps
    end
  end
end
