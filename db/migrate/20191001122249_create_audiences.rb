class CreateAudiences < ActiveRecord::Migration[5.2]
  def change
    create_table :audiences do |t|
      t.string :study_id
      t.string :question_id
      t.string :answer_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
