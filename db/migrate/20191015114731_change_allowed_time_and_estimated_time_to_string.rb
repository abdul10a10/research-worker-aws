class ChangeAllowedTimeAndEstimatedTimeToString < ActiveRecord::Migration[5.2]
  def change
    change_column :studies, :allowedtime, :string
    change_column :studies, :estimatetime, :string
  end
end
