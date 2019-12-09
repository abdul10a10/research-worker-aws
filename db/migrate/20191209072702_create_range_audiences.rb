class CreateRangeAudiences < ActiveRecord::Migration[5.2]
  def change
    create_table :range_audiences do |t|
      t.string :study_id
      t.string :question_id
      t.float :min_limit
      t.float :max_limit
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
