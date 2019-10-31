class Response < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :answer

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
