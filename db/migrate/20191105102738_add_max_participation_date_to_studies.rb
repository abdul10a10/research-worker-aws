class AddMaxParticipationDateToStudies < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :max_participation_date, :datetime
  end
end
