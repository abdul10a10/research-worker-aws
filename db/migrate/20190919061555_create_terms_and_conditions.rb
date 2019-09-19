class CreateTermsAndConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :terms_and_conditions do |t|
      t.string :country
      t.string :user_type
      t.string :title
      t.string :description
      t.timestamps
    end
  end
end
