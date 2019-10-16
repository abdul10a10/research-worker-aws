class AddIsAcceptedToEligibleCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :eligible_candidates, :is_accepted, :string
    add_column :eligible_candidates, :reject_reason, :text
  end
end
