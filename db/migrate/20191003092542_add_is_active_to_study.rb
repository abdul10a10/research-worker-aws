class AddIsActiveToStudy < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :is_active, :string
    add_column :studies, :is_complete, :string
  end
end
