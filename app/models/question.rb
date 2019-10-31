class Question < ApplicationRecord
  belongs_to :question_category
  belongs_to :question_type
  has_many :answers

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
