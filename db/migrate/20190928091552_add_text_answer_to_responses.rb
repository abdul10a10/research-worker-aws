class AddTextAnswerToResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :responses, :text_answer, :string
  end
end
