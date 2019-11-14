class AddOnlyWhitelistedToStudies < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :only_whitelisted, :integer
  end
end
