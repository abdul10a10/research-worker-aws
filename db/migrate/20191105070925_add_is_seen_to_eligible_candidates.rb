class AddIsSeenToEligibleCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :eligible_candidates, :is_seen, :integer
  end
end
