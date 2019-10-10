class TermsAndCondition < ApplicationRecord

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
  
end
