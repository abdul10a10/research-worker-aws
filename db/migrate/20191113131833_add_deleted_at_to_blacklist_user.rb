class AddDeletedAtToBlacklistUser < ActiveRecord::Migration[5.2]
  def change
    add_column :blacklist_users, :deleted_at, :datetime
    add_column :whitelist_users, :deleted_at, :datetime
  end
end
