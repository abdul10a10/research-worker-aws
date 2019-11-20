class ChangeWalletFromIntegerToFloatInUser < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :amount, :float
    change_column :users, :wallet, :float
    change_column :studies, :study_wallet, :float
  end
end
