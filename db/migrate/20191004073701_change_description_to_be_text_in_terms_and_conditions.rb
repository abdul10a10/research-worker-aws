class ChangeDescriptionToBeTextInTermsAndConditions < ActiveRecord::Migration[5.2]
  def change
    change_column :privacy_policies, :description, :text
  end
end
