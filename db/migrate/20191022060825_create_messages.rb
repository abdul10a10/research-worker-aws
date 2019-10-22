class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :reciever_id
      t.string :sender_id
      t.string :subject
      t.text :message
      t.string :status
      t.integer :seen_status
      t.datetime :seen_time
      t.timestamps
    end
  end
end
