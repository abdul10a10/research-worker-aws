class AddEmailConfirmationFunctionality < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :authentication_token_sent_at, :datetime
    add_column :users, :user_referral_code, :string

    add_index :users, :user_referral_code, unique: true
  end
end
