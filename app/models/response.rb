class Response < ApplicationRecord
  # belongs_to :user

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
