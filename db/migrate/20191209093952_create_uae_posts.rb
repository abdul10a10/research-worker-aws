class CreateUaePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :uae_posts do |t|
      t.string :city
      t.string :po_box_number
      t.timestamps
    end
  end
end
