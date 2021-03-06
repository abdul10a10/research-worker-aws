class Question < ApplicationRecord
  belongs_to :question_category
  belongs_to :question_type
  has_many :answers
  has_one :range_answer
  has_many :audiences
  has_many :range_audiences
  has_many :responses
  has_many :range_responses

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
