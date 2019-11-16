class Answer < ApplicationRecord
    belongs_to :question
    has_many :audiences
    has_many :responses

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
