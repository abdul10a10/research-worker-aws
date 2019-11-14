class Study < ApplicationRecord
  has_many :audiences
  has_many :eligible_candidates
  has_many :transactions
  has_many :whitelist_users
  has_many :blacklist_users
  belongs_to :user
  
  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
