class CreateEligibleCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :eligible_candidates do |t|
      t.string :user_id
      t.string :study_id
      t.string :is_attempted
      t.datetime :start_time
      t.datetime :submit_time
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
