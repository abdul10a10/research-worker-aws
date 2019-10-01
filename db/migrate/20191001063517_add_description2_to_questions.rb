class AddDescription2ToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :description2, :string
  end
end
