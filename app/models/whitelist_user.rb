class WhitelistUser < ApplicationRecord
  belongs_to :user
  belongs_to :study

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
