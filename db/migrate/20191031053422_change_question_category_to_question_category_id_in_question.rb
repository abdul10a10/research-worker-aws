class ChangeQuestionCategoryToQuestionCategoryIdInQuestion < ActiveRecord::Migration[5.2]
  def change
    rename_column :questions, :question_type, :question_type_id
    rename_column :questions, :question_category, :question_category_id
  end
end
