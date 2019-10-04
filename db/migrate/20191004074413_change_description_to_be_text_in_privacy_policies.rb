class ChangeDescriptionToBeTextInPrivacyPolicies < ActiveRecord::Migration[5.2]
  def change
    change_column :terms_and_conditions, :description, :text
  end
end
