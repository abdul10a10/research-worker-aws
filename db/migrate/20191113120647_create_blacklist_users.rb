class CreateBlacklistUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :blacklist_users do |t|
      t.string :user_id
      t.string :study_id
      t.timestamps
    end
  end
end
