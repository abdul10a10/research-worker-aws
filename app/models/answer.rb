class Answer < ApplicationRecord
    belongs_to :question
    has_many :audiences

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
