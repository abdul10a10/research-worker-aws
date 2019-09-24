class AddAddressAndPhoneNumberToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :address, :string
    add_column :users, :contact_number, :integer
  end
end
