class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :transaction_id
      t.string :study_id
      t.string :payment_type
      t.string :sender_id
      t.string :receiver_id
      t.integer :amount
      t.text :description
      t.timestamps
    end
  end
end
