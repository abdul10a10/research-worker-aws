class CreateTermsOfUses < ActiveRecord::Migration[5.2]
  def change
    create_table :terms_of_uses do |t|
      t.string :description
      t.timestamps
    end
  end
end
