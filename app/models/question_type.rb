class QuestionType < ApplicationRecord
    has_many :questions

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
