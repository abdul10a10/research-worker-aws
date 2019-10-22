class ChangeMessageToDescriptionInMessage < ActiveRecord::Migration[5.2]
  def change
    rename_column :messages, :message, :description
  end
end
