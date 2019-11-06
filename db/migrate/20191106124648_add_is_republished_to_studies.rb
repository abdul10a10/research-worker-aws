class AddIsRepublishedToStudies < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :is_republish, :integer
  end
end
