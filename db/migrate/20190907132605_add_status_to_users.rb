class AddStatusToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :status, :string
    add_column :users, :deleted_at, :datetime
  end
end
