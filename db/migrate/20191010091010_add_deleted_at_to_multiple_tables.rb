class AddDeletedAtToMultipleTables < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :deleted_at, :datetime
    add_column :notifications, :deleted_at, :datetime
    add_column :privacy_policies, :deleted_at, :datetime
    add_column :question_categories, :deleted_at, :datetime
    add_column :question_types, :deleted_at, :datetime
    add_column :studies, :deleted_at, :datetime
    add_column :terms_and_conditions, :deleted_at, :datetime
    add_column :terms_of_uses, :deleted_at, :datetime
  end
end
