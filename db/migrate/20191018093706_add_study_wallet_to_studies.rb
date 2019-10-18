class AddStudyWalletToStudies < ActiveRecord::Migration[5.2]
  def change
    add_column :studies, :study_wallet, :integer, default: 0
  end
end
