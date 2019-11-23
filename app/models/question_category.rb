class QuestionCategory < ApplicationRecord
    has_many :questions
    has_one_attached :image

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
