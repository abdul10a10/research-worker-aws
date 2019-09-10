class AddVarificationStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :verification_status, :string
  end
end
