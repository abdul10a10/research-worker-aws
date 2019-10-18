class AddIsPaidToStudies < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :is_paid, :integer
  end
end
