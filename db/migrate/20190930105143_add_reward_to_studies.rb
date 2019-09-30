class AddRewardToStudies < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :reward, :string
    add_column :studies, :is_published, :string
  end
end
