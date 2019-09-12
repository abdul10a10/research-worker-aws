class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :type
      t.integer :user_id
      t.string :message
      t.string :redirect_url
      t.string :seen_status
      t.string :status
      t.datetime :seen_time
      t.timestamps
    end
  end
end