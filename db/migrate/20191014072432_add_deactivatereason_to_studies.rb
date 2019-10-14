class AddDeactivatereasonToStudies < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :deactivate_reason, :text
  end
end
