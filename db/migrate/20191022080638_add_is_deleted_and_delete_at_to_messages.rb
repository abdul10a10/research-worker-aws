class AddIsDeletedAndDeleteAtToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :deleted_at, :datetime
    add_column :messages, :is_archive, :integer
  end
end
