class Study < ApplicationRecord
  # has_many :audiences  
  belongs_to :user
  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
